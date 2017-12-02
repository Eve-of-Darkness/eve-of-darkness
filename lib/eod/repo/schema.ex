defmodule EOD.Repo.Schema do
  @moduledoc """
  This is meant to wrap and insulate the use of Ecto directly
  in the project. For each of the table modules.  I know a lot
  of the Ecto functionality is used; however, this should help
  keep it's introduction into the project at a minimum.  This
  is meant to be `used` in any module where you are defining
  data for a table.
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      import Ecto.Changeset
      import Ecto.Query, only: [from: 2]
    end
  end
end
