# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :eve_of_darkness, ecto_repos: [EOD.Repo]

import_config "#{Mix.env()}.exs"
