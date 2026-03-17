defmodule RinhaV2Web.Router do
  use Plug.Router
  import Plug.Conn
  require Logger

  alias RinhaV2.Transactions.Transaction
  alias RinhaV2.Clients.Client
  alias RinhaV2.Repo

  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  post "/clientes/:id/transacoes" do
    body = conn.body_params
    client_id = conn.params["id"] |> String.to_integer()

    Logger.info("Creating transaction for client #{client_id} with body #{inspect(body)}")

    with %Client{} = client <- Repo.get(Client, client_id),
         body <- body |> Map.put("client_id", client.id),
         {:ok, %{client: client}} <-
           Ecto.Multi.new()
           |> Ecto.Multi.insert(:transaction, Transaction.create_changeset(body))
           |> Ecto.Multi.update(:client, fn _ ->
             saldo =
               if body["tipo"] == "c" do
                 client.saldo + body["valor"]
               else
                 client.saldo - body["valor"]
               end

             Client.update_changeset(client, %{saldo: saldo})
           end)
           |> Repo.transaction() do
      json(conn, :created, client)
    else
      {:error, changeset} ->
        json(conn, :unprocessable_entity, %{error: parse_changeset_errors(changeset)})

      {:error, _, changeset, _} ->
        json(conn, :unprocessable_entity, %{error: parse_changeset_errors(changeset)})

      nil ->
        json(conn, :not_found, %{error: "Cliente não encontrado"})
    end
  end

  match _ do
    send_resp(conn, :not_found, "Not Found")
  end

  defp json(conn, status, data) do
    conn
    |> put_status(status)
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end

  defp parse_changeset_errors(changeset) do
    Enum.map(changeset.errors, fn {field, {message, _}} -> "#{field}: #{message}" end)
  end
end
