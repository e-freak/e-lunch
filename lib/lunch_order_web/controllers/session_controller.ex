defmodule LunchOrderWeb.SessionController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Users.User
  alias LunchOrder.Locks

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

          {:ok, jwt, _full_claims} =  LunchOrder.Guardian.encode_and_sign(user)
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

end
