defmodule RinhaV2.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def up do
    create table(:transactions) do
      add :client_id, references(:clients, on_delete: :delete_all)
      add :valor, :integer, default: 0
      add :tipo, :string
      add :descricao, :string

      timestamps()
    end

    create index(:transactions, [:client_id, :inserted_at])
  end

  def down do
    drop table(:transactions)
  end
end
