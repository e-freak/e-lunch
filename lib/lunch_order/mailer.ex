defmodule LunchOrder.Mailer do
  use Bamboo.Mailer, otp_app: :lunch_order
end

defmodule LunchOrder.Email do
  import Bamboo.Email

  def send_email(from, to, bcc, subject, body) do
    new_email()
    |> from(from)
    |> to(to)
    |> bcc(bcc)
    |> subject(subject)
    |> text_body(body)
    |> LunchOrder.Mailer.deliver_now
  end

  def send_email_html(from, to, subject, body) do
    new_email()
    |> from(from)
    |> to(to)
    |> subject(subject)
    |> html_body(body)
    |> LunchOrder.Mailer.deliver_now
  end

end
