defmodule LunchOrderWeb.SessionController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Users.User
  alias LunchOrder.Locks
  alias LunchOrder.AuthTokens

  def login(conn, %{"email" => email, "password" => password_base64}) do

    # アカウントロックの確認
    {result, lock} = Locks.check_lock(email)

    if result == :error do
      # アカウントロック中
      conn
      |> put_status(401)
      |> render("error.json", message: "Could not login")
    else
      # パスワードはBase64でデコードする
      password = Base.decode64!(password_base64)
      case User.find_and_confirm_password(email, password) do
        {:ok, user} ->
          Locks.reset_lock(lock)

          {:ok, jwt, full_claims} =  LunchOrder.Guardian.encode_and_sign(user, %{}, ttl: {60, :minute}) # 60分間有効
          {:ok, _token} = AuthTokens.after_encode_and_sign(user, full_claims, jwt, %{}) # DB登録
          conn
          |> render("login.json", user: user, jwt: jwt)
        {:error, _reason} ->
          Locks.update_lock(email, lock)
          conn
          |> put_status(401)
          |> render("error.json", message: "Could not login")
      end

    end

  end

  def logout(conn, _params) do
    token = LunchOrder.Guardian.get_token(conn)
    case confirm_token(token) do
      {:ok, claims} ->
        AuthTokens.on_revoke(claims, token, %{})
        render(conn, "logout.json", message: "Logout success")
      {:error, _} ->
        conn
        |> put_status(401)
        |> render("logout.json", message: "Logout error")
    end
  end

  defp confirm_token(token) do
    case LunchOrder.Guardian.decode_and_verify(token) do
      {:ok, clams} ->
        AuthTokens.on_verify(clams, token, %{})
      _ ->
        {:error, :not_decode_and_verify}
    end
  end

end
