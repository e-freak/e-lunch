defmodule LunchOrderWeb.MenuControllerTest do
  use LunchOrderWeb.ConnCase

  alias LunchOrder.Menus
  alias LunchOrder.Menus.Menu

  @create_attrs %{name: "some name", price: 42, symbol: "some symbol"}
  @update_attrs %{name: "some updated name", price: 43, symbol: "some updated symbol"}
  @invalid_attrs %{name: nil, price: nil, symbol: nil}

  def fixture(:menu) do
    {:ok, menu} = Menus.create_menu(@create_attrs)
    menu
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all menus", %{conn: conn} do
      conn = get conn, menu_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create menu" do
    test "renders menu when data is valid", %{conn: conn} do
      conn = post conn, menu_path(conn, :create), menu: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, menu_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some name",
        "price" => 42,
        "symbol" => "some symbol"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, menu_path(conn, :create), menu: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update menu" do
    setup [:create_menu]

    test "renders menu when data is valid", %{conn: conn, menu: %Menu{id: id} = menu} do
      conn = put conn, menu_path(conn, :update, menu), menu: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, menu_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "name" => "some updated name",
        "price" => 43,
        "symbol" => "some updated symbol"}
    end

    test "renders errors when data is invalid", %{conn: conn, menu: menu} do
      conn = put conn, menu_path(conn, :update, menu), menu: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete menu" do
    setup [:create_menu]

    test "deletes chosen menu", %{conn: conn, menu: menu} do
      conn = delete conn, menu_path(conn, :delete, menu)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, menu_path(conn, :show, menu)
      end
    end
  end

  defp create_menu(_) do
    menu = fixture(:menu)
    {:ok, menu: menu}
  end
end
