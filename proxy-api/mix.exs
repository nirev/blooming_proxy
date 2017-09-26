defmodule BoomingProxy.Mixfile do
  use Mix.Project

  def project do
    [
      app: :booming_proxy,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {BoomingProxy.Application, []},
      extra_applications: [:logger, :runtime_tools, :amqp]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:amqp, "~> 0.3.0"},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0.2"},
      {:poison, "~> 3.1.0"},
      {:gettext, "~> 0.13.1"},
      {:cowboy, "~> 1.0"},
    ]
  end
end
