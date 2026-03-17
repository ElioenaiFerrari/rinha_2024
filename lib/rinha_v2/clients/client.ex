defmodule RinhaV2.Clients.Client do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:limite, :saldo]}
  schema "clients" do
    field(:limite, :integer, default: 0)
    field(:saldo, :integer, default: 0)

    timestamps()
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:limite, :saldo])
    |> validate_required([:limite, :saldo], message: "Campos obrigatórios não preenchidos")
    |> validate_number(:limite, greater_than: 0, message: "Limite deve ser maior que 0")
    |> validate_number(:saldo, greater_than: 0, message: "Saldo deve ser maior que 0")
  end

  def update_changeset(client, attrs) do
    client
    |> cast(attrs, [:limite, :saldo])
    |> validate_required([:limite, :saldo], message: "Campos obrigatórios não preenchidos")
    |> validate_number(:limite, greater_than: 0, message: "Limite deve ser maior que 0")
    |> validate_number(:saldo, greater_than: 0, message: "Saldo deve ser maior que 0")
    |> foreign_key_constraint(:client_id, message: "Cliente não encontrado")
  end
end
