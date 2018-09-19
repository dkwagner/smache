FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

RUN apt-get update && apt-get install wget -y

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
  && dpkg -i erlang-solutions_1.0_all.deb

RUN apt-get update

RUN apt-get install esl-erlang -y && apt-get install elixir -y

COPY . .

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

RUN /bin/bash -c "source .env \
  && mix do deps.get, compile, release --verbose --env=prod \
  && cp -R _build/prod/rel/smache/releases smache_release"
