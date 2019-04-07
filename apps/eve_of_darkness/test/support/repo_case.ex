defmodule EOD.RepoCase do
  use ExUnit.CaseTemplate
  @moduledoc "Meant to be used with tests that need database functionality"

  using do
    quote do
      import Ecto.Query, only: [from: 2]
      import EOD.Repo.Factory
      alias EOD.Repo
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EOD.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EOD.Repo, {:shared, self()})
    end

    :ok
  end
end
