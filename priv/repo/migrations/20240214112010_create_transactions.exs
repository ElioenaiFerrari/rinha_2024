defmodule Rinha2024.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def up do
    create table(:transactions) do
      add(:client_id, references(:clients, column: :id, on_delete: :delete_all))
      add(:valor, :integer)
      add(:descricao, :string)
      add(:tipo, :string)

      add(:realizada_em, :utc_datetime, default: fragment("CURRENT_TIMESTAMP"))
    end
  end
end
