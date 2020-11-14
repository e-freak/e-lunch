defmodule LunchOrderWeb.OrderController do
  use LunchOrderWeb, :controller

  alias LunchOrder.Orders
  alias LunchOrder.Users

  require Logger

  action_fallback LunchOrderWeb.FallbackController

  def create(conn, params) do
    access_user = LunchOrder.Guardian.get_user_from_token(conn)
    is_same_user = (String.to_integer(params["user"]) == access_user.id)

    if is_same_user do
      # ログ
      log_create(access_user, params)

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
      log_error(access_user.id, params["user"])

      conn
      |> put_status(403)
      |> render("error.json", error: "You cannot edit other user's order")
    end
  end

  # ログ出力
  defp log_create(user, params) do

    name = user.email |> String.split("@") |> List.first
    floor = params["floor"]
    month = params["month"]

    order_log = params["orders"]
    |> Enum.map(fn order -> Enum.join(order, ",") end)
    |> Enum.join("|")

    message = "[info] OrderController.create <#{name}> floor:#{floor},month:#{month},order:|#{order_log}|"
    Logger.error(message)

  end

  defp log_error(access_user, order_user) do

    access_user_name = Users.get_user!(access_user) |> Map.get(:email) |> String.split("@") |> List.first
    order_user_name = Users.get_user!(order_user) |> Map.get(:email) |> String.split("@") |> List.first
    message = "[error] OrderController.create <#{access_user_name}> tryed to change <#{order_user_name}> order"
    Logger.error(message)

  end

  # 個人注文一覧(月)
  def show(conn, param) do
    orders = Orders.list_orders(param)
    user = Users.get_user!(param["user"])

    check_orders(orders, user)

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

  # 注文が重複した場合のチェック 
  defp check_orders(orders, user) do
    date_list = Enum.map(orders, fn(order) -> order.date end)
    if Enum.count(date_list) != Enum.count(Enum.uniq(date_list)) do
      name = user.email |> String.split("@") |> List.first
      Logger.error("[error] OrderController.check_orders found multi orders <#{name}>")
      subject = "(管理者用) #{user.name} さんの注文内容に問題あり！"
      body = ""

      from = Application.get_env(:lunch_order, :from_address)
      to = Application.get_env(:lunch_order, :bcc_address)
      LunchOrder.Email.send_email(from, to, [], [], subject, body)
    end
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

  # 発注FAX文書用データ(monthly)
  def show_fax_month(conn, %{"month" => month}) do

    orders = Orders.list_all_orders_month(month)
    users = Users.list_users

    render(conn, "fax_orders.json", orders: orders, users: users)

  end

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
