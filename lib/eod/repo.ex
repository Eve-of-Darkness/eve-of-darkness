defmodule EOD.Repo do
  @moduledoc """
  This is the data access to the database.  For more information you
  should see https://hexdocs.pm/ecto/getting-started.html
  """
  use Ecto.Repo,
    otp_app: :eve_of_darkness,
    adapter: Ecto.Adapters.Postgres
end
