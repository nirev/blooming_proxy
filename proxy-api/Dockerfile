FROM elixir:1.5.1-slim

ARG BUILD_PACKAGES="git-core openssh-client g++ make libssl-dev"
ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8
ENV MIX_ENV=prod

# create deploy user first to prevent packages from hijacking our canonical uid
RUN adduser --disabled-password --system --uid 1000 deploy

# install build deps
RUN apt-get update && \
    apt-get dist-upgrade -q -y && \
    apt-get install -q -y --no-install-recommends $BUILD_PACKAGES

COPY . /home/deploy/app

WORKDIR /home/deploy/app
RUN chown -Rh deploy /home/deploy

# copy actual app sources
USER deploy
WORKDIR /home/deploy/app
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix compile

# start service
CMD [ "mix", "phx.server"]
