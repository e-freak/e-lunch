defmodule LunchOrderWeb.SessionController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Users.User

  def login(conn, %{"email" => email, "password" => password}) do

    case User.find_and_confirm_password(email, password) do
      {:ok, user} ->
         {:ok, jwt, _full_claims} =  LunchOrder.Guardian.encode_and_sign(user)
         # {:ok, claims} = LunchOrder.Guardian.decode_and_verify(jwt)
         # IO.inspect(claims)

         conn
         |> render("login.json", user: user, jwt: jwt)
      {:error, _reason} ->
        conn
        |> put_status(401)
        |> render("error.json", message: "Could not login")
    end
  end
end