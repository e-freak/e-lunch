defmodule LunchOrder.AdminPipeline do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _params) do
    user = LunchOrder.Guardian.get_user_from_token(conn)
    if user.is_admin do
      conn
    else
      conn
      |> send_resp(400, "Bad Request")
    end
  end

end
