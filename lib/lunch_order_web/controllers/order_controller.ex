defmodule LunchOrderWeb.OrderController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Orders
  alias LunchOrder.Orders.Order

  alias LunchOrder.Users

  action_fallback LunchOrderWeb.FallbackController

  # def index(conn, _params) do
  #   orders = Orders.list_orders()
  #   render(conn, "index.json", orders: orders)
  # end

  # def create(conn, %{"order" => order_params}) do
  #   with {:ok, %Order{} = order} <- Orders.create_order(order_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", order_path(conn, :show, order))
  #     |> render("show.json", order: order)
  #   end
  # end


  def create(conn, params) do
    access_user = LunchOrder.Guardian.get_user_from_token(conn)
    is_same_user = (String.to_integer(params["user"]) == access_user.id)

    if is_same_user do
      # 注文の更新
      Orders.create_order(params)

      # フロアの更新
      Users.get_user!(params["user"])
      |> Users.update_user(%{floor: params["floor"]})

      # show
      orders = Orders.list_orders(params)
      user = Users.get_user!(params["user"])
      render(conn, "orders.json", floor: user.floor, orders: orders)
    else
      # 他人の情報を変更できない
      conn
      |> put_status(403)
      |> render("error.json", error: "You cannot edit other user's order")
    end
  end

  # 個人注文一覧(月)
  def show(conn, param) do
    orders = Orders.list_orders(param)
    user = Users.get_user!(param["user"])

    floor = if Enum.empty?(orders) do
      # 注文無しの場合は、ユーザー設定に従う。最後に設定した階
      user.floor
    else
      # 注文ありの場合は、その月の最後の注文の設定階に従う
      last_order = Enum.max_by(orders, fn order -> Date.to_erl(order.date) end)
      last_order.floor
    end

    render(conn, "orders.json", floor: floor, orders: orders)
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

  # def delete(conn, %{"id" => id}) do
  #   order = Orders.get_order!(id)
  #   with {:ok, %Order{}} <- Orders.delete_order(order) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end

  def outline(conn, %{"month" => month}) do

    outline = Orders.outline_order(%{month: month, users: Users.list_users})

    render(conn, "outline.json", outline: outline)

  end

  # 注文詳細
  def show_detail(conn, %{"year_month" => year_month}) do

    details = Orders.detail_order(%{year_month: year_month, users: Users.list_users})
    render(conn, "detail.json", details: details)

  end


end
