defmodule HttpTestTarget.Plug do
  @moduledoc """
  Trivial Plug for the http11test Cowboy target: any method, any path
  returns 200 "ok\\n". Mirrors the Bandit target so the only difference
  between them is the underlying HTTP server (Cowboy vs Bandit).
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "ok\n")
  end
end

defmodule HttpTestTarget.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: HttpTestTarget.Plug, options: [port: 80]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: HttpTestTarget.Supervisor)
  end
end
