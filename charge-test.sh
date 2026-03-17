#!/bin/bash

URL="http://127.0.0.1:4000/clientes/1/transacoes"
TMP_FILE=$(mktemp)

# quantidade de requests pré-geradas (ajusta se quiser)
TOTAL=1000

for ((i=1; i<=TOTAL; i++)); do
  VALOR=$((RANDOM % 1000))

  if (( RANDOM % 2 )); then
    TIPO="c"
  else
    TIPO="d"
  fi

  echo "$URL POST {\"valor\":$VALOR,\"tipo\":\"$TIPO\",\"descricao\":\"Compra $i\"}" >> "$TMP_FILE"
done

siege -c 255 -t 10s \
  -H "Content-Type: application/json" \
  -f "$TMP_FILE"

rm "$TMP_FILE"