FROM elixir:1.17-alpine

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs .
RUN mix deps.get && mix deps.compile

COPY lib ./lib
RUN mix compile

EXPOSE 80
CMD ["mix", "run", "--no-halt"]
