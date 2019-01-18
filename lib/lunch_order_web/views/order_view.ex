defmodule LunchOrderWeb.OrderView do
  use LunchOrderWeb, :view
  alias LunchOrderWeb.OrderView

  def render("index.json", %{orders: orders}) do
    %{data: render_many(orders, OrderView, "order.json")}
  end



  def render("show.json", %{order: order}) do
    %{data: render_one(order, OrderView, "order.json")}
  end

  def render("order.json", %{order: order}) do
    %{id: order.id,
      user_id: order.user_id,
      date: order.date,
      floor: order.floor,
      lunch_type: order.lunch_type,
      lunch_count: order.lunch_count}
  end

  # 個人注文一覧(月)
  def render("orders.json", %{floor: floor, orders: orders}) do

    # ここら辺が関数型言語っぽい
    orderList = createList(orders)
    %{floor: floor, orders: orderList}
  end

    # 全員注文一覧(日)
  def render("all_orders.json", %{orders: orders, users: users}) do
    Enum.group_by(orders,
      fn(order) -> order.floor end,
      fn(order) -> create_order(order, users) end)
  end

  # ここら辺が関数型言語っぽい
  # 一時変数を作ってリストを構築するやり方はできない。
  defp createList(orders) do
    for order <- orders do
      day = order.date.day
      [day, order.lunch_type, order.lunch_count]
    end
  end


  defp create_order(order, users) do
    id = String.to_integer(order.user_id)
    user = Enum.find(users, fn u -> u.id == id end)
    [id, user.name, order.lunch_type]
  end

end
