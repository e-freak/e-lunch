defmodule LunchOrder.Closing do

  alias LunchOrder.Orders
  alias LunchOrder.Users
  alias LunchOrder.Email
  alias LunchOrder.Menus

  def close_order do
    today = Timex.now("Asia/Tokyo") |> DateTime.to_date |> Date.to_string
    orders = Orders.list_all_orders today

    if !Enum.empty?(orders) do
      users = LunchOrder.Users.list_users
      # ユーザーメール通知
      notify_order(orders)

      # 管理者メール通知
      notify_admin(today, orders, users)
    end
  end

  # ユーザーに本日の注文内容をメール通知する
  defp notify_order(order_list) do
    from_address = Application.get_env(:lunch_order, :from_address)

    Enum.each(order_list, fn order ->
      user = Users.get_user!(order.user_id)
      date = Date.to_string(order.date) |> String.replace("-", "/")
      lunch = Menus.get_symbol!(order.lunch_type)
      subject = "(本日のお弁当) #{date} ｜#{lunch}｜#{order.lunch_count}個｜#{order.floor}階｜ #{user.name}"
      body = "※注文内容の変更は、受け付けていません。"
      Email.send_email(from_address, user.email, [], [], subject, body)
    end)
  end

  # 管理者に締め処理完了をメール通知する
  defp notify_admin(date, orders, users) do
    # 件名
    date = String.replace(date, "-", "/")
    subject = "(管理者用) #{date} 締め処理が完了しました"

    # URL
    url = Application.get_env(:lunch_order, :fax_url)

    # 注文合計
    outline = create_table_outline(orders)

    # 注文詳細
    detail = create_table_detail(orders, users)

    # HTML本文作成
    body = url <> "<br><br>" <> outline <> "<br>" <> detail

    from = Application.get_env(:lunch_order, :from_address)
    to = Application.get_env(:lunch_order, :admin_address)
    bcc = Application.get_env(:lunch_order, :bcc_address)
    Email.send_email_html(from, to, bcc, subject, body)
  end

  # 注文合計の表
  defp create_table_outline(orders) do

    menus = Menus.list_menus
    outline = Enum.map(menus, fn menu ->
      count = Enum.filter(orders, fn order -> order.lunch_type == menu.id end)
      |> Enum.reduce(0, fn order, acc -> order.lunch_count + acc end)
      %{symbol: menu.symbol, count: count}
    end)
    sum = Enum.reduce(outline, 0, fn data, acc -> data.count + acc end)

    title = "<tr>" <> Enum.map_join(outline, &("<td>" <> &1.symbol <> "</td>")) <> "<td>合計</td></tr>"
    item = "<tr>" <> Enum.map_join(outline, &("<td>" <> to_string(&1.count) <> "</td>")) <> "<td>#{sum}</td></tr>"

    "<table border=\"1\" cellpadding=\"3\" cellspacing=\"0\">" <> title <> item <> "</table>"
  end

  # 注文詳細の表
  defp create_table_detail(orders, users) do
    orders = Enum.sort(orders, &(&1.floor <= &2.floor))
    title = "<tr><td>座席</td><td>名前</td><td>注文内容</td><td>個数</td></tr>"
    items = Enum.map(orders, fn order ->
      user = Enum.find(users, fn user -> user.id == String.to_integer(order.user_id) end)
      menu = LunchOrder.Menus.get_symbol!(order.lunch_type)
      "<tr><td>#{order.floor}階</td><td>#{user.name}</td><td>#{menu}</td><td>#{order.lunch_count}</td></tr>"
    end)

    "<table border=\"1\" cellpadding=\"3\" cellspacing=\"0\">" <> title <> Enum.join(items) <> "</table>"
  end

end
