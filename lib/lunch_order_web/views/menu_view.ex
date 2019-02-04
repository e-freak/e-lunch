defmodule LunchOrderWeb.MenuView do
  use LunchOrderWeb, :view
  alias LunchOrderWeb.MenuView

  def render("index.json", %{menus: menus}) do
    Enum.map(menus, fn menu -> [menu.id, menu.name, menu.price] end)
  end

  def render("show.json", %{menu: menu}) do
    %{data: render_one(menu, MenuView, "menu.json")}
  end

  def render("menu.json", %{menu: menu}) do
    %{id: menu.id,
      name: menu.name,
      symbol: menu.symbol,
      price: menu.price}
  end
end
