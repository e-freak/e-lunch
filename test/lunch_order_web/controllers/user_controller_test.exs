defmodule LunchOrderWeb.UserControllerTest do
  use LunchOrderWeb.ConnCase

  alias LunchOrder.Users
  alias LunchOrder.Users.User

  @create_attrs %{email: "some email", is_admin: true, name: "some name", organization: "some organization", password_hash: "some password_hash", user_id: "some user_id"}
  @update_attrs %{email: "some updated email", is_admin: false, name: "some updated name", organization: "some updated organization", password_hash: "some updated password_hash", user_id: "some updated user_id"}
  @invalid_attrs %{email: nil, is_admin: nil, name: nil, organization: nil, password_hash: nil, user_id: nil}

  def fixture(:user) do
    {:ok, user} = Users.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, user_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "email" => "some email",
        "is_admin" => true,
        "name" => "some name",
        "organization" => "some organization",
        "password_hash" => "some password_hash",
        "user_id" => "some user_id"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put conn, user_path(conn, :update, user), user: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, user_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "email" => "some updated email",
        "is_admin" => false,
        "name" => "some updated name",
        "organization" => "some updated organization",
        "password_hash" => "some updated password_hash",
        "user_id" => "some updated user_id"}
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete conn, user_path(conn, :delete, user)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, user_path(conn, :show, user)
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
