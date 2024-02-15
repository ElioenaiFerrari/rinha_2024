defmodule Rinha2024.Repo.Migrations.CreateClients do
  use Ecto.Migration

  def up do
    create table(:clients) do
      add(:saldo, :integer)
      add(:limite, :integer)
    end
  end
end
