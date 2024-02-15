defmodule Rinha2024.Clients do
  alias Rinha2024.Repo
  alias Rinha2024.Clients.Client

  def get_by_id(id) do
    case Repo.get(Rinha2024.Clients.Client, id) do
      nil -> {:error, "usuário não encontrado"}
      client -> {:ok, client}
    end
  end

  def create(attrs) do
    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end
end
