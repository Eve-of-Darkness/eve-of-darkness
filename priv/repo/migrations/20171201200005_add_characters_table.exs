defmodule EOD.Repo.Migrations.AddCharactersTable do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add :id,         :uuid,    primary_key: true
      add :account_id, :uuid
      add :realm,      :integer
      add :name,       :string
      timestamps()
    end

    create index(:characters, [:account_id])

    execute """
            CREATE UNIQUE INDEX index_characters_lowercase_name
            ON characters
            USING btree (lower((name)::text));
            """
  end
end
