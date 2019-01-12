use Mix.Config

config :eve_of_darkness, EOD.Repo,
  database: System.get_env("EOD_DATABASE_NAME") || "eod_prod",
  username: System.get_env("EOD_DATABASE_USERNAME") || "postgres",
  password: System.get_env("EOD_DATABASE_PASSWORD") || "postgres",
  hostname: System.get_env("EOD_DATABASE_HOSTNAME") || "localhost",
  pool_size: 20
