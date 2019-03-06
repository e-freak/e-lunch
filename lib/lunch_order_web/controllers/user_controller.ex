defmodule LunchOrderWeb.UserController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Users
  alias LunchOrder.Users.User

  action_fallback LunchOrderWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    LunchOrder.Log.log_data
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
    id = user_params["id"]
    user = Users.get_user!(id)

    access_user = get_user_from_token(conn)
    is_same_user = (String.to_integer(id) == access_user.id)
    password_only = map_size(user_params) == 2 && Map.has_key?(user_params, "password")
    case {access_user.is_admin, is_same_user, password_only} do
      # 一般ユーザーが変更できるのは自分自身のパスワードのみ
      {false, false, _} ->
        render(conn, "error.json", error: "You cannot edit other user's info")
      {false, true, false} ->
        render(conn, "error.json", error: "You can edit password only")
      _ ->
        with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
          render(conn, "show.json", user: user)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def private(conn, _param) do
    # トークンからIDを取得
    user = get_user_from_token(conn)
    render(conn, "show.json", user: user)
  end

  defp get_user_from_token(conn) do
    auth_header = Enum.find(conn.req_headers, fn header -> elem(header, 0) == "authorization" end)
    token = String.slice(elem(auth_header, 1), 7..-1)
    decode = LunchOrder.Guardian.decode_and_verify(token)
    id = String.to_integer(elem(decode, 1)["sub"])
    Users.get_user!(id)
  end
end
