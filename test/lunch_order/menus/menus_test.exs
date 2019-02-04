defmodule LunchOrder.MenusTest do
  use LunchOrder.DataCase

  alias LunchOrder.Menus

  describe "menus" do
    alias LunchOrder.Menus.Menu

    @valid_attrs %{name: "some name", price: 42, symbol: "some symbol"}
    @update_attrs %{name: "some updated name", price: 43, symbol: "some updated symbol"}
    @invalid_attrs %{name: nil, price: nil, symbol: nil}

    def menu_fixture(attrs \\ %{}) do
      {:ok, menu} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Menus.create_menu()

      menu
    end

    test "list_menus/0 returns all menus" do
      menu = menu_fixture()
      assert Menus.list_menus() == [menu]
    end

    test "get_menu!/1 returns the menu with given id" do
      menu = menu_fixture()
      assert Menus.get_menu!(menu.id) == menu
    end

    test "create_menu/1 with valid data creates a menu" do
      assert {:ok, %Menu{} = menu} = Menus.create_menu(@valid_attrs)
      assert menu.name == "some name"
      assert menu.price == 42
      assert menu.symbol == "some symbol"
    end

    test "create_menu/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Menus.create_menu(@invalid_attrs)
    end

    test "update_menu/2 with valid data updates the menu" do
      menu = menu_fixture()
      assert {:ok, menu} = Menus.update_menu(menu, @update_attrs)
      assert %Menu{} = menu
      assert menu.name == "some updated name"
      assert menu.price == 43
      assert menu.symbol == "some updated symbol"
    end

    test "update_menu/2 with invalid data returns error changeset" do
      menu = menu_fixture()
      assert {:error, %Ecto.Changeset{}} = Menus.update_menu(menu, @invalid_attrs)
      assert menu == Menus.get_menu!(menu.id)
    end

    test "delete_menu/1 deletes the menu" do
      menu = menu_fixture()
      assert {:ok, %Menu{}} = Menus.delete_menu(menu)
      assert_raise Ecto.NoResultsError, fn -> Menus.get_menu!(menu.id) end
    end

    test "change_menu/1 returns a menu changeset" do
      menu = menu_fixture()
      assert %Ecto.Changeset{} = Menus.change_menu(menu)
    end
  end
end
