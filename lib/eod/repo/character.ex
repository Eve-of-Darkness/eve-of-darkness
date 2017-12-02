defmodule EOD.Repo.Character do
  use EOD.Repo.Schema

  schema "characters" do
    field :realm, :integer
    field :name,  :string
    belongs_to :account, EOD.Repo.Account
    timestamps()
  end

  def find_by_name(query \\ __MODULE__, name) when is_binary(name) do
    from(
      c in query,
      where: fragment("lower(?)", c.name) == ^String.downcase(name)
    )
  end

  def name_taken?(query \\ __MODULE__, name) when is_binary(name) do
    from(find_by_name(query, name), select: [:id])
    |> EOD.Repo.one
    |> case do
      nil -> false
      _ -> true
    end
  end

  def invalid_name?(name) when is_binary(name) do
    case Regex.run(~r/^[a-z]{3,20}$/, name) do
      nil -> true
      [_] -> false
    end
  end
  def invalid_name?(_), do: true
end
