defmodule LunchOrderWeb.HolidayController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Holidays
  alias LunchOrder.Holidays.Holiday
  alias LunchOrder.Users

  require Logger

  action_fallback LunchOrderWeb.FallbackController


  def show(conn, %{"year_month" => year_month}) do
    list = String.split(year_month, "-")
    year = List.first list
    month = List.last list

    holiday = case Holidays.get_holiday(year, month) do
      nil -> %Holiday{days: []}
      holiday -> holiday
    end
    render(conn, "show.json", holiday: holiday)
  end

  def update(conn, params) do
    [year, month] = String.split(params["year_month"], "-")

    month_start = Date.from_iso8601!(params["year_month"] <> "-01")
    days = Date.days_in_month(month_start)
    filtered_params = Enum.filter(params["days"], fn day -> day <= days end)

    with {:ok, %Holiday{} = holiday} <- Holidays.update_holiday(year, month, filtered_params) do

      # メール通知
      send_email(conn, year, month, filtered_params)

      # 当日以降の休日に設定されていた注文を削除する
      today = Timex.now("Asia/Tokyo") |> DateTime.to_date
      users = Users.list_users
      Enum.map(holiday.days, fn day -> Date.new(String.to_integer(year), String.to_integer(month), day) |> elem(1) end)
      |> Enum.filter(fn date -> Date.compare(date, today) == :gt end)
      |> Enum.map(fn date ->
        # 注文削除
        orders = Date.to_string(date) |> LunchOrder.Orders.delete_orders
        if !Enum.empty?(orders) do
          # ログ出力
          user_list = Enum.map(orders, fn order -> Enum.find(users, fn user -> user.id == String.to_integer(order.user_id) end) end)
          log_delete_order(date, user_list)
        end
      end)



      render(conn, "show.json", holiday: holiday)
    end
  end

  defp send_email(conn, year, month, days) do
    login_user = LunchOrder.Guardian.get_user_from_token(conn)

    # ログ
    log_set_holiday(login_user, year, month, days)

    subject = "(管理者用) #{login_user.name} さんが #{year}年#{String.to_integer(month)}月 の祝日を設定しました"
    body = "祝日設定: #{Enum.join(days, ", ")}"

    from = Application.get_env(:lunch_order, :from_address)
    to = Application.get_env(:lunch_order, :admin_address)
    bcc = Application.get_env(:lunch_order, :bcc_address)
    LunchOrder.Email.send_email(from, to, [], bcc, subject, body)
  end

  defp log_set_holiday(user, year, month, days) do

    user_name = String.split(user.email, "@") |> List.first
    message = "[info] HolidayController.update <#{user_name}> #{year}/#{month} |#{Enum.join(days, ",")}|"
    Logger.error(message)

  end

  defp log_delete_order(date, users) do

    user_name_log = Enum.map_join(users, ",", fn user ->
      String.split(user.email, "@") |> List.first
    end)

    message = "[info] HolidayController.update delete order <#{date}> |#{user_name_log}|"
    Logger.error(message)

  end
end
