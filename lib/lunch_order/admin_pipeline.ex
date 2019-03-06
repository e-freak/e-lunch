defmodule LunchOrder.AdminPipeline do
  import Plug.Conn

  alias LunchOrder.Users

  def init(default), do: default

  def call(conn, _params) do
    user = get_user_from_token(conn)
    if user.is_admin do
      conn
    else
      conn
      |> send_resp(400, "Bad Request")
    end
  end


  defp get_user_from_token(conn) do
    auth_header = Enum.find(conn.req_headers, fn header -> elem(header, 0) == "authorization" end)
    token = String.slice(elem(auth_header, 1), 7..-1)
    decode = LunchOrder.Guardian.decode_and_verify(token)
    id = String.to_integer(elem(decode, 1)["sub"])
    Users.get_user!(id)
  end


end
