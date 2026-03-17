# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/_/elixir - for the build image (official)
#   - https://hub.docker.com/_/debian - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#
# Using official Elixir images which are more reliable
# OTP 27 requires GLIBC 2.34+, so we need Debian Bookworm (12) or newer
ARG BUILDER_IMAGE="elixir:1.18.2-otp-27"
ARG RUNNER_IMAGE="debian:bookworm-slim"

FROM ${BUILDER_IMAGE} AS builder

# set build ENV
ENV MIX_ENV="prod"

# prepare build dir
WORKDIR /app

# install build dependencies
# Adding retry logic and --fix-missing for network issues
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends build-essential curl || \
  (apt-get update -y && apt-get install -y --no-install-recommends --fix-missing build-essential curl) && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib

# Compile the release
RUN mix compile --force

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

# Compile assets for production (if you have assets.deploy task)
# RUN mix assets.deploy

RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE} AS prod

ENV MIX_ENV="prod"
WORKDIR "/app"


RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN chown nobody /app

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/scheduler ./

# Copy static assets (important for LiveView!)
COPY --from=builder --chown=nobody:root /app/priv/static ./priv/static

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

ENTRYPOINT [ "./entrypoint.sh" ]


FROM elixir:1.18.2-otp-27-alpine AS dev

ENV MIX_ENV="dev"
WORKDIR /app

RUN apk add --no-cache build-base curl \
  && mix local.hex --force \
  && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

COPY config/config.exs config/${MIX_ENV}.exs config/
COPY entrypoint.sh entrypoint.sh

RUN mix deps.compile

COPY priv priv
COPY lib lib
RUN mix compile --force
COPY config/runtime.exs config/

RUN mix compile --force

RUN chmod +x entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]