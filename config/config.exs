import Config

config :rinha_2024, Rinha2024.Repo,
  database: "rinha2024",
  pool_size: 10,
  timeout: 10_000,
  queue_target: 10000,
  username: "postgres",
  password: "postgres",
  hostname: "postgres.rinha2024.local",
  port: 5432,
  show_sensitive_data_on_connection_error: true

config :rinha_2024,
  ecto_repos: [Rinha2024.Repo]
