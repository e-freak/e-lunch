defmodule LunchOrder.Menus do
  @moduledoc """
  The Menus context.
  """

  alias LunchOrder.Menus.Menu

  @doc """
  Gets a single menu.

  Raises `Ecto.NoResultsError` if the Menu does not exist.

  ## Examples

      iex> get_menu!(123)
      %Menu{}

      iex> get_menu!(456)
      ** (Ecto.NoResultsError)

  """
  def list_menus do
    [
      %Menu{id: 1, name: "普通弁当", price: 400, symbol: "○"},
      %Menu{id: 2, name: "普通弁当 ご飯大盛", price: 420, symbol: "大"},
      %Menu{id: 3, name: "普通弁当 ご飯小盛", price: 380, symbol: "小"},
      %Menu{id: 4, name: "おかずのみ", price: 350, symbol: "お"},
      %Menu{id: 5, name: "ご飯のみ", price: 200, symbol: "ご"},
      %Menu{id: 6, name: "牛丼", price: 400, symbol: "牛"},
      %Menu{id: 7, name: "カレーライス", price: 400, symbol: "カ"}
    ]
  end

  def get_menu!(id) do
    menus = list_menus()
    Enum.find(menus, fn menu -> menu.id == id end)
  end

  def get_price!(id) do
    menu = get_menu!(id)
    menu.price
  end

  def get_symbol!(id) do
    menu = get_menu!(id)
    menu.symbol
  end


end
