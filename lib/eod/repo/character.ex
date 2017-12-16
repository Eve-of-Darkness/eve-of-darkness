defmodule EOD.Repo.Character do
  use EOD.Repo.Schema

  @permitted ~w(realm name slot custom_mode eye_size lip_size eye_color
                hair_color face_type hair_style mood_type level class
                gender race model region strength dexterity constitution
                quickness intelligence piety empathy charisma account_id)a

  @required @permitted

  @name_format ~r/^[A-Z]{0,1}[a-z]{3,20}$/

  schema "characters" do
    field :realm, :integer
    field :name,  :string
    field :slot, :integer
    field :custom_mode, :integer
    field :eye_size, :integer
    field :lip_size, :integer
    field :eye_color, :integer
    field :hair_color, :integer
    field :face_type, :integer
    field :hair_style, :integer
    field :mood_type, :integer
    field :level, :integer
    field :class, :integer
    field :gender, :integer
    field :race, :integer
    field :model, :integer
    field :region, :integer
    field :strength, :integer
    field :dexterity, :integer
    field :constitution, :integer
    field :quickness, :integer
    field :intelligence, :integer
    field :piety, :integer
    field :empathy, :integer
    field :charisma, :integer
    belongs_to :account, EOD.Repo.Account
    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> validate_length(:name, min: 3, max: 20)
    |> validate_format(:name, @name_format)
    |> unique_constraint(:name, name: :index_characters_lowercase_name)
  end

  def new(params \\ %{}), do: changeset(%__MODULE__{}, params)

  def find_by_name(query \\ __MODULE__, name) when is_binary(name) do
    from(
      c in query,
      where: fragment("lower(?)", c.name) == ^String.downcase(name)
    )
  end

  def for_account(query \\ __MODULE__, %EOD.Repo.Account{id: id}) do
    from(
      c in query,
      where: c.account_id == ^id
    )
  end

  def for_realm(query \\ __MODULE__, realm) when is_atom(realm) do
    realm_num = case realm do
      :albion -> 1
      :midgard -> 2
      :hibernia -> 3
      _ -> 0
    end

    from(
      c in query,
      where: c.realm == ^realm_num
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
    case Regex.run(@name_format, name) do
      nil -> true
      [_] -> false
    end
  end
  def invalid_name?(_), do: true
end
