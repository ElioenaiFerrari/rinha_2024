defmodule Rinha2024.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rinha2024.Clients.Client
  @valid_types ~w(d c)

  @derive {Jason.Encoder, only: [:id, :valor, :descricao, :tipo, :realizada_em, :client_id]}
  schema "transactions" do
    field(:valor, :integer)
    field(:descricao, :string)
    field(:tipo, :string)
    field(:realizada_em, :utc_datetime, default: DateTime.utc_now(:second))

    belongs_to(:client, Client, foreign_key: :client_id)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:valor, :descricao, :tipo, :realizada_em])
    |> validate_required([:valor, :tipo, :descricao, :realizada_em])
    |> validate_inclusion(:tipo, @valid_types)
  end
end
