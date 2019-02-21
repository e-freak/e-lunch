defmodule LunchOrder.Notification do

  alias LunchOrder.Orders
  alias LunchOrder.Users
  alias LunchOrder.Email

  @lunch_names ["", "○", "大", "小", "お", "ご", "客", "牛", "カ"]
  def notify_order_by_email do

    today = Timex.now("Asia/Tokyo") |> DateTime.to_date
    orders = Orders.list_all_orders Date.to_string(today)

    for order <- orders do
      user = Users.get_user!(order.user_id)
      date = Date.to_string(order.date) |> String.replace("-", "/")
      lunch = Enum.at(@lunch_names, order.lunch_type)
      subject = "[TEST](本日のお弁当) #{date} ｜#{lunch}｜#{order.lunch_count}個｜#{order.floor}階｜ #{user.name}"
      body = "※注文内容の変更は、管理G担当者までご相談ください。"
      Email.send_email(user.email, subject, body)
    end

  end

end
