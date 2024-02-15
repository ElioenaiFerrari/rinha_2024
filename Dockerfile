FROM elixir:1.16-otp-25-alpine as builder

ENV MIX_ENV=prod

WORKDIR /app

RUN apk add --no-cache bash
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod && mix deps.compile

COPY config ./config

COPY lib ./lib
COPY priv ./priv
COPY test ./test
COPY entrypoint.sh ./entrypoint.sh


RUN chmod +x entrypoint.sh
RUN mix release

EXPOSE 4000

CMD ["bash", "-c", "./entrypoint.sh"]

