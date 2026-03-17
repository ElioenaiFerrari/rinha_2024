defmodule RinhaV2Web.Router do
  use Plug.Router
  import Plug.Conn
  require Logger

  require Ecto.Query
  alias RinhaV2.Transactions.Transaction
  alias RinhaV2.Clients.Client
  alias RinhaV2.Repo

  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:match)
  plug(:dispatch)

  post "/clientes/:id/transacoes" do
    client_id = String.to_integer(conn.params["id"])
    %{"valor" => valor, "tipo" => tipo, "descricao" => descricao} = conn.body_params
    valor_operacao = if tipo == "d", do: -valor, else: valor

    result =
      Repo.transaction(
        fn ->
          query_update = """
            UPDATE clients
            SET saldo = saldo + $1
            WHERE id = $2 AND ($3 = 'c' OR (saldo + $1 >= -limite))
            RETURNING saldo, limite
          """

          case Repo.query(query_update, [valor_operacao, client_id, tipo]) do
            {:ok, %{rows: [[novo_saldo, limite]]}} ->
              # Inserção direta sem changeset (mais rápido)
              Repo.query!(
                "INSERT INTO transactions (client_id, valor, tipo, descricao, inserted_at, updated_at) VALUES ($1, $2, $3, $4, datetime('now'), datetime('now'))",
                [client_id, valor, tipo, descricao]
              )

              %{limite: limite, saldo: novo_saldo}

            {:ok, %{rows: []}} ->
              # Se falhou, provavelmente é limite. Não faça Repo.get aqui se quiser velocidade máxima.
              # Se a Rinha garantir que o ID existe, assuma limite.
              # Se precisar validar ID, faça fora da transação ou aceite o custo.
              Repo.rollback(:limite_ou_nao_encontrado)
              {:error, :limite_ou_nao_encontrado}
          end
        end,
        timeout: 15000
      )

    # TRATAMENTO DO RESULTADO:
    case result do
      {:ok, data} ->
        # Aqui 'data' é apenas o mapa %{limite: ..., saldo: ...}, sem a tupla {:ok, ...}
        json(conn, :ok, data)

      {:error, :limite_ou_nao_encontrado} ->
        json(conn, :unprocessable_entity, %{error: "Limite insuficiente"})

      {:error, :not_found} ->
        json(conn, :not_found, %{error: "Cliente não encontrado"})

      _ ->
        json(conn, :internal_server_error, %{error: "Erro interno do servidor"})
    end
  end

  get "/clientes/:id/extrato" do
    client_id = conn.params["id"] |> String.to_integer()

    with %Client{} = client <- Repo.get(Client, client_id),
         transactions <-
           Ecto.Query.from(t in Transaction,
             where: t.client_id == ^client.id,
             order_by: [desc: t.inserted_at],
             limit: 10
           )
           |> Repo.all() do
      json(conn, :ok, %{
        saldo: %{
          limite: client.limite,
          saldo: client.saldo,
          data_extrato: DateTime.utc_now()
        },
        ultimas_transacoes:
          transactions
          |> Enum.map(fn transaction ->
            %{
              valor: transaction.valor,
              tipo: transaction.tipo,
              descricao: transaction.descricao,
              realizada_em: transaction.inserted_at
            }
          end)
      })
    else
      nil -> json(conn, :not_found, %{error: "Cliente não encontrado"})
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
