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

    # パスワードをBase64でデコードする
    password = Base.decode64!(user_params["password"])
    user_params = Map.put(user_params, "password", password)
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
    params = update_user_params(user_params, access_user.is_admin)
    case {access_user.is_admin, is_same_user} do
      # 一般ユーザーは他人の情報を変更できない
      {false, false} ->
        render(conn, "error.json", error: "You cannot edit other user's info")
      _ ->
        with {:ok, %User{} = user} <- Users.update_user(user, params) do
          render(conn, "show.json", user: user)
        end
    end
  end

  defp update_user_params(user_params, is_admin) do
    # パスワードをBase64でデコードする
    user_params = if Map.has_key?(user_params, "password") do
        Map.put(user_params, "password", Base.decode64!(user_params["password"]))
      else
        user_params
      end

    # 一般ユーザーが変更できるのはパスワードのみ
    if is_admin, do: user_params, else: Map.take(user_params, ["password"])
  end

  def delete(conn, %{"id" => id}) do

    user = Users.get_user!(id)
    with {:ok, %User{}} <- Users.delete_user(user) do
      # 注文を全て削除する
      LunchOrder.Orders.delete_orders_by_user(id)
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
