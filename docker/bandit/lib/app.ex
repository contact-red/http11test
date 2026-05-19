defmodule HttpTestTarget.Plug do
  @moduledoc """
  Trivial Plug for the http11test Bandit target: any method, any path
  returns 200 "ok\\n". The point is to exercise Bandit's HTTP parser, not
  to do anything useful in the response.
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
      {Bandit, plug: HttpTestTarget.Plug, scheme: :http, port: 80}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: HttpTestTarget.Supervisor)
  end
end
