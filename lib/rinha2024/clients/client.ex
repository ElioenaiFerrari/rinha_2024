defmodule Rinha2024.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rinha2024.Transactions.Transaction

  @derive {Jason.Encoder, only: [:id, :saldo, :limite]}
  schema "clients" do
    field(:saldo, :integer)
    field(:limite, :integer)

    has_many(:transactions, Transaction, foreign_key: :client_id)
  end

  @doc false
  def changeset(client, attrs) do
    client
    |> cast(attrs, [:saldo, :limite])
    |> validate_required([:saldo, :limite])
  end
end
