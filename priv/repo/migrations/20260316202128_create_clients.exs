defmodule RinhaV2.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def up do
    create table(:clients) do
      add :limite, :integer, default: 0
      add :saldo, :integer, default: 0

      timestamps()
    end
  end


  def down do
    drop table(:clients)
  end
end
