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
      # メール通知
      login_user = LunchOrder.Guardian.get_user_from_token(conn)
      send_email_for_create(login_user, user)

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

    login_user = LunchOrder.Guardian.get_user_from_token(conn)
    is_same_user = (String.to_integer(id) == login_user.id)

    params = update_user_params(user_params, login_user.is_admin)

    case {login_user.is_admin, is_same_user} do
      # 一般ユーザーは他人の情報を変更できない
      {false, false} ->
        render(conn, "error.json", error: "You cannot edit other user's info")
      _ ->
        with {:ok, %User{} = user} <- Users.update_user(user, params) do
          if !is_same_user do
            # メール通知
            send_email_for_update(login_user, user)
          end

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
      # メール通知
      login_user = LunchOrder.Guardian.get_user_from_token(conn)
      send_email_for_delete(login_user, user)

      # 注文を全て削除する
      LunchOrder.Orders.delete_orders_by_user(id)
      send_resp(conn, :no_content, "")
    end
  end

  def private(conn, _param) do
    # トークンからIDを取得
    user = LunchOrder.Guardian.get_user_from_token(conn)
    render(conn, "show.json", user: user)
  end

  defp send_email_for_create(login_user, user) do
    subject = "(管理者用) #{login_user.name} さんが #{user.name} さんのアカウントを作成しました"
    send_email(subject, user)
  end

  defp send_email_for_update(login_user, user) do
    subject = "(管理者用) #{login_user.name} さんが #{user.name} さんのアカウント情報を変更しました"
    send_email(subject, user)
  end

  defp send_email_for_delete(login_user, user) do
    subject = "(管理者用) #{login_user.name} さんが #{user.name} さんのアカウントを削除しました"
    send_email(subject, user)
  end

  defp send_email(subject, user) do
    # HTML本文作成
    organization = if user.organization == "RITS", do: "社員", else: "派遣"
    role = if user.is_admin, do: "管理者", else: "一般"
    header = "<tr><td>社員番号</td><td>氏名</td><td>メールアドレス</td><td>SP区分</td><td>ロール</td></tr>"
    data = "<tr><td>#{user.user_id}</td><td>#{user.name}</td><td>#{user.email}</td><td>#{organization}</td><td>#{role}</td></tr>"
    body = "<table border=\"1\" cellpadding=\"3\" cellspacing=\"0\">" <> header <> data <> "</table>"

    from = Application.get_env(:lunch_order, :from_address)
    to = Application.get_env(:lunch_order, :admin_address)
    bcc = Application.get_env(:lunch_order, :bcc_address)
    LunchOrder.Email.send_email_html(from, to, bcc, subject, body)
  end

end
