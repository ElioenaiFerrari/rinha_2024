import Config

config :rinha_v2, RinhaV2.Repo,
  database: "rinha_v2_dev.sqlite3",
  pool_size: 10

config :rinha_v2, :ecto_repos, [RinhaV2.Repo]
