defmodule LunchOrder.Alert do

  alias LunchOrder.Orders
  alias LunchOrder.Users
  alias LunchOrder.Email

  # 翌月以降の注文書作成アラート
  def notify_create_order do

    # 当月注文したユーザーのメールアドレスを取得
    year_month = Timex.now("Asia/Tokyo") |> DateTime.to_date |> Date.to_string |> String.slice(0..6) # YYYY-MM
    email_list = Orders.get_ordered_user_ids(year_month) |> convert_email_list

    from_address = Application.get_env(:lunch_order, :from_address)
    url = Application.get_env(:lunch_order, :url)
    subject = "■■■ 鳥取お弁当注文アラート ■■■"
    body = "翌月以降お弁当を注文する方は注文書を作成してください。\n\nお弁当注文システムのリンク\n#{url}"

    Email.send_email(from_address, [], [], email_list, subject, body)

  end

  # メールアドレスに変換
  defp convert_email_list(id_list) do
    users = Users.list_users
    Enum.map(id_list, fn id ->
      Enum.find(users, fn user -> user.id == id end)
      |> Map.get(:email)
    end)
  end

end
