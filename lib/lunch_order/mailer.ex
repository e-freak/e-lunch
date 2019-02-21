defmodule LunchOrder.Mailer do
  use Bamboo.Mailer, otp_app: :lunch_order
end

defmodule LunchOrder.Email do
  import Bamboo.Email


  def send_email(mail_address, subject, body) do
    new_email()
    |> to(mail_address)
    |> from("no-reply@phoenix.com")
    |> subject(subject)
    |> text_body(body)
    |> LunchOrder.Mailer.deliver_now
  end



end
