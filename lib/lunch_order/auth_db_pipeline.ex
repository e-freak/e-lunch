defmodule LunchOrder.Guardian.AuthDBPipeline do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _params) do

    token = LunchOrder.Guardian.get_token(conn)
    case confirm_token(token) do
      {:ok, _} ->
        conn
      _ ->
        send_resp(conn, 401, "unauthenticated")
        |> halt()
    end

  end

  defp confirm_token(token) do
    # トークンの内容が有効かどうか
    case LunchOrder.Guardian.decode_and_verify(token) do
      {:ok, clams} ->
        # トークンがDBに登録されているかどうか (ログアウトに対応)
        LunchOrder.AuthTokens.on_verify(clams, token, %{})
      _ ->
        {:error, "invalid_token"}
    end
  end

end
