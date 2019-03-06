defmodule LunchOrderWeb.HolidayView do
  use LunchOrderWeb, :view
  alias LunchOrderWeb.HolidayView

  def render("index.json", %{holidays: holidays}) do
    %{data: render_many(holidays, HolidayView, "holiday.json")}
  end

  def render("show.json", %{holiday: holiday}) do
    render_one(holiday, HolidayView, "holiday.json")
  end

  def render("holiday.json", %{holiday: holiday}) do
    holiday.days
  end
end
