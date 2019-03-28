defmodule LunchOrder.Closing do

  alias LunchOrder.Orders
  alias LunchOrder.Users
  alias LunchOrder.Email
  alias LunchOrder.Menus

  def close_order do

    today = Timex.now("Asia/Tokyo") |> DateTime.to_date |> Date.to_string
    order_list = Orders.list_all_orders today

    if !Enum.empty?(order_list) do
      # メール通知
      notify_order(order_list)
      # 注文ログ出力
      log_data(today, order_list)
    end
  end

  defp notify_order(order_list) do
    from_address = Application.get_env(:lunch_order, :from_mail_address)

    Enum.each(order_list, fn order ->
      user = Users.get_user!(order.user_id)
      date = Date.to_string(order.date) |> String.replace("-", "/")
      lunch = Menus.get_symbol!(order.lunch_type)
      subject = "[TEST](本日のお弁当) #{date} ｜#{lunch}｜#{order.lunch_count}個｜#{order.floor}階｜ #{user.name}"
      body = "※注文内容の変更は、管理G担当者までご相談ください。"
      Email.send_email(user.email, from_address, subject, body)
    end)
  end

  defp log_data(date, order_list) do

    # フォルダ生成
    dir_path = "log/" <> String.slice(date, 0..-4) # log/YYYY-MM
    File.mkdir dir_path

    # ログファイル生成
    file_path = dir_path <> "/" <> date <> ".log"
    {:ok, file} = File.open(file_path, [:write, :utf8, :append])

    users = LunchOrder.Users.list_users

    IO.write file, "座席, 名前, 注文内容, 個数\n"
    Enum.each(order_list, fn order ->
      user = Enum.find(users, fn user -> user.id == String.to_integer(order.user_id) end)
      IO.write file, "#{user.floor}階, #{user.name}, #{Menus.get_symbol!(order.lunch_type)}, #{order.lunch_count}\n"
    end)

    File.close file
  end

end
