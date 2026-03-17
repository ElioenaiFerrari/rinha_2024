defmodule RinhaV2.Repo do
  use Ecto.Repo,
    otp_app: :rinha_v2,
    adapter: Ecto.Adapters.SQLite3
end
