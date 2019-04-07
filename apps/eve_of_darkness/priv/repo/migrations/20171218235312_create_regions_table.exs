defmodule EOD.Repo.Migrations.CreateRegionsTable do
  use Ecto.Migration

  def change do
    create table(:regions, primary_key: false) do
      add :id,          :uuid,     primary_key: true
      add :region_id,   :integer
      add :name,        :string
      add :description, :string
      add :enabled,     :boolean
    end

    create unique_index(:regions, [:region_id])
  end
end
