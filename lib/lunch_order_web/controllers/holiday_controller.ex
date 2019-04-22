defmodule LunchOrderWeb.HolidayController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Holidays
  alias LunchOrder.Holidays.Holiday

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

      today = Timex.now("Asia/Tokyo") |> DateTime.to_date
      Enum.each(holiday.days, fn day ->
        {:ok, date} = Date.new(String.to_integer(year), String.to_integer(month), day)
        # 当日以降の休日に設定されていた注文を削除する
        if (Date.compare(date, today) == :gt) do
          LunchOrder.Orders.delete_orders Date.to_string(date)
        end
      end)

      # メール通知
      send_email(conn, year, month, filtered_params)

      render(conn, "show.json", holiday: holiday)
    end
  end

  defp send_email(conn, year, month, days) do
    login_user = LunchOrder.Guardian.get_user_from_token(conn)
    subject = "(管理者用) #{login_user.name} さんが #{year}年#{String.to_integer(month)}月 の祝日を設定しました"
    body = "祝日設定: #{Enum.join(days, ", ")}"

    from = Application.get_env(:lunch_order, :from_address)
    to = Application.get_env(:lunch_order, :admin_address)
    bcc = Application.get_env(:lunch_order, :bcc_address)
    LunchOrder.Email.send_email(from, to, [], bcc, subject, body)
  end
end
