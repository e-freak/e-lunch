defmodule LunchOrder.Mailer do
  use Bamboo.Mailer, otp_app: :lunch_order
end

defmodule LunchOrder.Email do
  import Bamboo.Email

  def send_email(to, from, subject, body) do
    new_email()
    |> to(to)
    |> from(from)
    |> subject(subject)
    |> text_body(body)
    |> LunchOrder.Mailer.deliver_now
  end

end
