defmodule Rinha2024.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Rinha2024.Repo,
      {Plug.Cowboy, scheme: :http, plug: Rinha2024Web.Router, options: [port: 4000]},
      {Task.Supervisor, name: :transactions},
      {Task.Supervisor, name: :history}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rinha2024.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
