defmodule LunchOrderWeb.OrderController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Orders
  alias LunchOrder.Orders.Order

  alias LunchOrder.Users

  action_fallback LunchOrderWeb.FallbackController

  def index(conn, _params) do
    orders = Orders.list_orders()
    render(conn, "index.json", orders: orders)
  end

  # def create(conn, %{"order" => order_params}) do
  #   with {:ok, %Order{} = order} <- Orders.create_order(order_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", order_path(conn, :show, order))
  #     |> render("show.json", order: order)
  #   end
  # end


  def create(conn, params) do

    # 注文の更新
    if Orders.create_order(params) do
      # フロアの更新
      user = Users.get_user!(params["user"])
      Users.update_user(user, %{floor: params["floor"]})

      # show
      orders = Orders.list_orders(params)
      user = Users.get_user!(params["user"])
      render(conn, "orders.json", floor: user.floor, orders: orders)
    else
      conn
      |> put_status(400)
      |> render("error.json", error: "invalid order date")
    end


  end

  # 個人注文一覧(月)
  def show(conn, param) do
    # order = Orders.get_order(user)
    # render(conn, "show.json", order: order)

    orders = Orders.list_orders(param)
    user = Users.get_user!(param["user"])
    render(conn, "orders.json", floor: user.floor, orders: orders)
    # render(conn, "index.json", orders: orders)
  end

  def show_all(conn, %{"date" => date}) do

    orders = Orders.list_all_orders(date)
    users = Users.list_users
    render(conn, "all_orders.json", orders: orders, users: users, date: date)

  end

  # 発注FAX文書用データ
  def show_fax_data(conn, %{"date" => date}) do

    orders = Orders.list_all_orders(date)
    users = Users.list_users

    render(conn, "fax_orders.json", orders: orders, users: users)

  end

  # def show(conn, %{"id" => id}) do
  #   order = Orders.get_order!(id)
  #   render(conn, "show.json", order: order)
  # end

  def update(conn, %{"id" => id, "order" => order_params}) do
    order = Orders.get_order!(id)

    with {:ok, %Order{} = order} <- Orders.update_order(order, order_params) do
      render(conn, "show.json", order: order)
    end
  end

  def delete(conn, %{"id" => id}) do
    order = Orders.get_order!(id)
    with {:ok, %Order{}} <- Orders.delete_order(order) do
      send_resp(conn, :no_content, "")
    end
  end

  def outline(conn, %{"month" => month}) do

    outline = Orders.outline_order(%{month: month, users: Users.list_users})

    render(conn, "outline.json", outline: outline)

  end



end
