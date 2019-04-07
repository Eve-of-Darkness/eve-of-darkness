defmodule EOD.Repo.Migrations.AddLocInfoToCharacter do
  use Ecto.Migration

  def change do
    alter table("characters") do
      add :x_loc, :float, default: 0.0
      add :y_loc, :float, default: 0.0
      add :z_loc, :float, default: 0.0
      add :heading, :integer, default: 0
    end
  end
end
