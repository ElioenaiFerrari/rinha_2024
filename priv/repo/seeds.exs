alias Rinha2024.Clients

clients = [
  %{
    saldo: 0,
    limite: 100_000
  },
  %{
    saldo: 0,
    limite: 80_000
  },
  %{
    saldo: 0,
    limite: 1_000_000
  },
  %{
    saldo: 0,
    limite: 10_000_000
  },
  %{
    saldo: 0,
    limite: 500_000
  }
]

Enum.each(clients, fn attrs ->
  Clients.create(attrs)
end)
