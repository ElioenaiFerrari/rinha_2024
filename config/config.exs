import Config

config :rinha_v2, RinhaV2.Repo,
  database: "rinha.db",
  # Mantenha 1 para evitar "database is locked"
  pool_size: 1,
  # Se muitas requisições chegarem juntas, elas esperam mais antes de dar erro:
  queue_target: 5000,
  queue_interval: 10000,
  # Timeout da transação em si
  timeout: 15000,
  # PRAGMAs cruciais para performance
  journal_mode: :wal,
  cache_size: -64000,
  synchronous: :normal,
  temp_store: :memory

config :rinha_v2, :ecto_repos, [RinhaV2.Repo]
