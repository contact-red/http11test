defmodule HttpTestTarget.MixProject do
  use Mix.Project

  def project do
    [
      app: :http_test_target,
      version: "0.1.0",
      elixir: "~> 1.16",
      deps: deps()
    ]
  end

  def application do
    [
      mod: {HttpTestTarget.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:bandit, "~> 1.5"},
      {:plug, "~> 1.16"}
    ]
  end
end
