defmodule BuiltWithPhoenixWeb.Plugs.HeathCheck do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(%{request_path: "/_healthy"} = conn, _) do
    serve_pass!(conn, "HEALTHY")
  end

  def call(%{request_path: "/_ready"} = conn, _) do
    serve_pass!(conn, "READY")
  end

  def call(conn, _), do: conn

  def serve_pass!(conn, msg) do
    conn |> send_resp(200, msg) |> halt()
  end
end
