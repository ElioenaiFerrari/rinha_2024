defmodule Rinha2024.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha_2024,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :ecto, :postgrex, :jason],
      mod: {Rinha2024.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.7"},
      {:ecto, "~> 3.11"},
      {:ecto_sql, "~> 3.11"},
      {:jason, "~> 1.4"},
      {:postgrex, "~> 0.17.4"}
    ]
  end

  def aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"]
    ]
  end
end
