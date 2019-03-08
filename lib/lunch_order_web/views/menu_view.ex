defmodule LunchOrderWeb.MenuView do
  use LunchOrderWeb, :view

  def render("index.json", %{menus: menus}) do
    Enum.map(menus, fn menu -> [menu.id, menu.name, menu.symbol, menu.price] end)
  end

end
