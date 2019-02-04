defmodule LunchOrderWeb.UserController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Users
  alias LunchOrder.Users.User

  action_fallback LunchOrderWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end


  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, user_params) do
    user = Users.get_user!(user_params["id"])

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def private(conn, _param) do
    IO.inspect "--private---"

    auth_header = Enum.find(conn.req_headers, fn header ->
      elem(header, 0) == "authorization"
    end)

    token = String.slice(elem(auth_header, 1), 7..-1)
    decode = LunchOrder.Guardian.decode_and_verify(token)
    id = String.to_integer(elem(decode, 1)["sub"])
    user = Users.get_user!(id)
    IO.inspect user
    IO.inspect "--end---"
    render(conn, "show.json", user: user)
  end
end
