defmodule LunchOrder.Guardian do
  use Guardian, otp_app: :lunch_order

  alias LunchOrder.Repo
  alias LunchOrder.Users
  alias LunchOrder.Users.User

  def subject_for_token(resource, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = to_string(resource.id)
    {:ok, sub}
  end
  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    id = claims["sub"]
    resource = Repo.get(User, id)
    {:ok,  resource}
  end
  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  def get_user_from_token(conn) do
    auth_header = Enum.find(conn.req_headers, fn header -> elem(header, 0) == "authorization" end)
    token = String.slice(elem(auth_header, 1), 7..-1)
    decode = LunchOrder.Guardian.decode_and_verify(token)
    id = String.to_integer(elem(decode, 1)["sub"])
    Users.get_user!(id)
  end

end
