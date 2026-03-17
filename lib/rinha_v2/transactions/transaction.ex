defmodule RinhaV2.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias RinhaV2.Clients.Client

  @derive {Jason.Encoder, only: [:valor, :tipo, :descricao]}
  schema "transactions" do
    field(:valor, :integer, default: 0)
    field(:tipo, :string)
    field(:descricao, :string)
    belongs_to(:client, Client)

    timestamps()
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:valor, :tipo, :descricao, :client_id])
    |> validate_required([:valor, :tipo, :descricao, :client_id],
      message: "Campos obrigatórios não preenchidos"
    )
    |> validate_inclusion(:tipo, ["c", "d"], message: "Tipo deve ser 'c' ou 'd'")
    |> validate_number(:valor, greater_than: 0, message: "Valor deve ser maior que 0")
    |> validate_length(:descricao,
      max: 255,
      message: "Descrição deve ter no máximo 255 caracteres"
    )
    |> foreign_key_constraint(:client_id,
      message: "Cliente não encontrado"
    )
  end
end
