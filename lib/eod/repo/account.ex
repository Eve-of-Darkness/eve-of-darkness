defmodule EOD.Repo.Account do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "accounts" do
    field :username, :string
    field :password, :string
    timestamps()
  end

  def changeset(%__MODULE__{}=struct, params \\ %{}) do
    import Ecto.Changeset

    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 3, max: 200)
    |> validate_length(:password, min: 8, max: 200)
    |> unique_constraint(:username, name: :index_accounts_lowercase_username)
    |> hash_password
  end

  def new(params \\ %{}), do: changeset(%__MODULE__{}, params)

  def correct_password?(%__MODULE__{password: hash}, password)
  when is_binary(hash) and is_binary(password),
    do: Comeonin.Pbkdf2.checkpw(password, hash)
  def correct_password?(_, _), do: Comeonin.Pbkdf2.dummy_checkpw

  defp hash_password(%Ecto.Changeset{changes: %{password: password}}=changeset) do
    import Ecto.Changeset
    put_change(changeset, :password, Comeonin.Pbkdf2.hashpwsalt(password))
  end
  defp hash_password(changeset), do: changeset
end
