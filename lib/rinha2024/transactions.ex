defmodule Rinha2024.Transactions do
  alias Rinha2024.Repo
  alias Rinha2024.Transactions.Transaction
  alias Rinha2024.Clients
  alias Rinha2024.Clients.Client
  import Ecto.Query

  def create(client_id, attrs) do
    with {:ok, client} <- Clients.get_by_id(client_id),
         {:ok, transaction} <-
           %Transaction{}
           |> Transaction.changeset(attrs)
           |> Ecto.Changeset.put_assoc(:client, client)
           |> Repo.insert(),
         {:ok, client} <-
           client
           |> Ecto.Changeset.change()
           |> Client.changeset(%{saldo: client.saldo + transaction.valor})
           |> Repo.update() do
      {:ok, client}
    end
  end

  def last(client_id) do
    from(
      t in Transaction,
      where: t.client_id == ^client_id,
      order_by: [desc: t.realizada_em],
      limit: 10
    )
    |> Repo.all()
  end
end
