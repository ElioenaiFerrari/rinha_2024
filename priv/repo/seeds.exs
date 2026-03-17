alias RinhaV2.Clients.Client
alias RinhaV2.Repo

Client.create_changeset(%{limite: 1000, saldo: 1000})
|> Repo.insert()
