defmodule LunchOrderWeb.PageController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Users.User
  alias LunchOrder.Orders

  def index(conn, _params) do
    render conn, "index.html"
  end


  # def login(conn, %{"session" => %{"email" => email, "password" => password}}) do
  def login(conn, %{"email" => email, "password" => password}) do

    case User.find_and_confirm_password(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome")
        |> redirect(to: page_path(conn, :order_list))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "ユーザー名/パスワードが不正です")
        |> redirect(to: page_path(conn, :index))
    end
  end

  def order_list(conn, _params) do
    orders = Orders.get_today_order()
    IO.inspect orders
    IO.inspect "----orders----"

    render conn, "order_list.html", orders: [orders]

  end



  def delete(conn, _) do
    conn
    |> Hello.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end
end
