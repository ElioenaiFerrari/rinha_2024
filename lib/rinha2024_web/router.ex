defmodule Rinha2024Web.Router do
  use Plug.Router
  import Plug.Conn
  alias Rinha2024.Transactions
  alias Rinha2024.Clients
  require Logger

  plug(:match)
  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [{:json, json_decoder: Jason, json_encoder: Jason}])
  plug(:dispatch)

  def json(conn, status, body) do
    Logger.info("responding with #{status} and body #{inspect(body)}")

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Jason.encode!(body))
  end

  def translate_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  post "/clientes/:id/transacoes" do
    task =
      Task.Supervisor.async(:transactions, fn ->
        id = conn.params["id"]
        params = Map.delete(conn.params, "id")

        Logger.info("creating transaction for client with id #{id} and params #{inspect(params)}")

        case Transactions.create(id, params) do
          {:ok, client} ->
            {:ok,
             %{
               "saldo" => client.saldo,
               "limite" => client.limite
             }}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:bad_request, %{"error" => translate_changeset_errors(changeset)}}

          {:error, msg} ->
            {:internal_server_error, %{"error" => msg}}
        end
      end)

    {status, payload} = Task.await(task, 10_000)
    json(conn, status, payload)
  end

  get "/clientes/:id/extrato" do
    task =
      Task.Supervisor.async(:history, fn ->
        id = conn.params["id"]

        with {:ok, client} <- Clients.get_by_id(id),
             transactions <- Transactions.last(client.id) do
          %{
            "saldo" => %{
              "total" => client.saldo,
              "data_extrato" => DateTime.utc_now(),
              "limite" => client.limite
            },
            "ultimas_transacoes" =>
              Enum.map(
                transactions,
                &%{
                  "valor" => &1.valor,
                  "descricao" => &1.descricao,
                  "tipo" => &1.tipo,
                  "realizada_em" => &1.realizada_em
                }
              )
          }
        end
      end)

    payload = Task.await(task, 10_000)
    json(conn, :ok, payload)
  end

  match _ do
    json(conn, :not_found, %{"error" => "rota não encontrada"})
  end
end
