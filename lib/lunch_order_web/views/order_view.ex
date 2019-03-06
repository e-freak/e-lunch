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
    %{floor: floor, orders: orderList, is_close_today: is_close_order_today()}
  end

  # 全員注文一覧(日)
  @time_limit ~T[09:30:00]
  def render("all_orders.json", %{orders: orders, users: users, date: date}) do

    # 締め処理完了フラグ
    is_close = is_close_order(date)

    Enum.group_by(orders,
      fn(order) -> order.floor end,
      fn(order) -> create_order(order, users) end
    )
    |> Map.put(:is_close, is_close)

  end

  # 発注FAX文書用
  def render("fax_orders.json", %{orders: orders, users: users}) do

    # 社員か派遣か
    %{
      "RITS" => Enum.filter(orders, fn order -> is_rits?(order, users) end) |> count_menu_by_floor,
      "Others" => Enum.filter(orders, fn order -> is_rits?(order, users) == false end) |> count_menu_by_floor
    }

  end



  # 注文合計
  def render("outline.json", %{outline: outline}) do
    Enum.group_by(outline,
      fn(data) -> if data.organization == "RITS", do: "RITS", else: "Others" end,
      fn(data) -> [data.id, data.name, data.sum] end)
  end

  def render("detail.json", %{details: details}) do
    Enum.group_by(details,
      fn(data) -> if data.organization == "RITS", do: "RITS", else: "Others" end,
      fn(data) ->
        %{id: data.id,
          floor: data.floor,
          name: data.name,
          amount: data.amount,
          orders: data.orders}
      end)
  end

  # エラー
  def render("error.json", %{error: error}) do
    %{error: error}
  end

  defp is_close_order(date) do
    now = Timex.now("Asia/Tokyo")
    today = DateTime.to_date now
    time = DateTime.to_time now
    order_date = Date.from_iso8601!(date)
    order_date < today || (order_date == today && Time.compare(time, @time_limit) == :gt)
  end

  defp is_close_order_today do
    now = Timex.now("Asia/Tokyo")
    time = DateTime.to_time now
    Time.compare(time, @time_limit) == :gt
  end

  defp is_rits?(order, users) do
    id = String.to_integer(order.user_id)
    user = Enum.find(users, fn u -> u.id == id end)
    user.organization == "RITS"
  end



  @floor_list 5..9
  defp count_menu_by_floor(orders) do
    Map.new(@floor_list, fn floor ->
      floor_orders = Enum.filter(orders, fn order -> order.floor == floor end)
      {floor, count_menu(floor_orders)}
    end)

  end

  @menu_ids 1..8
  defp count_menu(orders) do
    Enum.map(@menu_ids, fn lunch_type ->
      Enum.reduce(orders, 0, fn order, acc ->
        acc + if order.lunch_type == lunch_type, do: order.lunch_count, else: 0 end)
    end)
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
