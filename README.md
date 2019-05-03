# Eve of Darkness

[![Build Status](https://travis-ci.org/Eve-of-Darkness/eve-of-darkness.svg?branch=master)](https://travis-ci.org/Eve-of-Darkness/eve-of-darkness)

Clone of Dark Age of Camelot open source server project known as Dawn of Light.  This
project aims to be a new-age implementation of the project with a focus on
flexibility and scalability.

## Development Requirements

 * Elixir 1.7.3
 * NodeJS 10.15.3
 * PostgreSQL 10+

## Up And Running

If you're familiar with an Elixir project this is pretty cut and dry; however,
there may be a few zingers with the project in it's current state.  Here is a
quick list commands that _should_ get you up and running in development.

```bash

# From the root of the project
mix deps.get
mix compile
mix ecto.create
mix ecto.migrate

# Starts both the web service and the development game server
iex -S mix phx.server
```

```bash

# The frontend development runs seperately and is found inside
# app/eod_web_frontend/
npm install
npm run dev
```

## Project Tests

This project uses Travis for it's CI testing, but for a quick reference the
project must follow the standard tests, a style guide check, as well as a
standard formatting check from mix.

```bash
mix test
mix credo -a
mix format --check-formatted
```

The astute among you will probably notice a lack of front-end tests; if anyone
wants to help take on that portion of the project better feel free ;)
