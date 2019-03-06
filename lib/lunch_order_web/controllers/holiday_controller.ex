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

    with {:ok, %Holiday{} = holiday} <- Holidays.update_holiday(year, month, params["days"]) do

      today = Timex.now("Asia/Tokyo") |> DateTime.to_date
      Enum.each(holiday.days, fn day ->
        {:ok, date} = Date.new(String.to_integer(year), String.to_integer(month), day)
        # 当日以降の休日に設定されていた注文を削除する
        if (Date.compare(date, today) == :gt) do
          LunchOrder.Orders.delete_orders Date.to_string(date)
        end
      end)

      render(conn, "show.json", holiday: holiday)
    end
  end

  def delete(conn, %{"id" => id}) do
    holiday = Holidays.get_holiday!(id)
    with {:ok, %Holiday{}} <- Holidays.delete_holiday(holiday) do
      send_resp(conn, :no_content, "")
    end
  end
end
