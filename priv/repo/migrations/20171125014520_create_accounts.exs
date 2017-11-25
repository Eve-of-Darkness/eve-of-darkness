defmodule EOD.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id,       :uuid,    primarky_key: true
      add :username, :string
      add :password, :string
      timestamps()
    end

    execute """
            CREATE UNIQUE INDEX index_accounts_lowercase_username
            ON accounts
            USING btree (lower((username)::text));
            """
  end
end
