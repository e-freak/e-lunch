defmodule LunchOrderWeb.MenuController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Menus

  action_fallback LunchOrderWeb.FallbackController

  def index(conn, _params) do
    menus = Menus.list_menus()
    render(conn, "index.json", menus: menus)
  end

end
