defmodule LunchOrderWeb.SessionController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Users.User

  def login(conn, %{"email" => email, "password" => password_base64}) do

    # パスワードはBase64でデコードする
    password = Base.decode64!(password_base64)
    case User.find_and_confirm_password(email, password) do
      {:ok, user} ->
         {:ok, jwt, _full_claims} =  LunchOrder.Guardian.encode_and_sign(user)
         conn
         |> render("login.json", user: user, jwt: jwt)
      {:error, _reason} ->
        conn
        |> put_status(401)
        |> render("error.json", message: "Could not login")
    end
  end
end
