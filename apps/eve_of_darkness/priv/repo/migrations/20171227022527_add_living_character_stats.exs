defmodule EOD.Repo.Migrations.AddLivingCharacterStats do
  use Ecto.Migration

  def change do
    alter table("characters") do
      add :max_hp, :integer, default: 100
      add :max_mana, :integer, default: 100
      add :max_endurance, :integer, default: 100
      add :max_concentration, :integer, default: 100

      add :current_hp, :integer, default: 100
      add :current_mana, :integer, default: 100
      add :current_endurance, :integer, default: 100
      add :current_concentration, :integer, default: 100
    end
  end
end
