# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :eod_web_backend,
  namespace: EOD.Web

config :eod_web_backend, EOD.Web.Guardian,
  issuer: "eod_web_backend",
  secret_key: "+O1HqEB86yXQkqqHKmcedPtdzqvQwF0CRBachsHTMOx+fI4g+cL4cPkYe4H3xaBA"

# Configures the endpoint
config :eod_web_backend, EOD.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "abE0OEmvsboVWAnwU6oOBOcDCW/YPguOGmIubCYZ0/RFZcR0V8emsp0/MV1vUYFX",
  render_errors: [view: EOD.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: EOD.Web.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
