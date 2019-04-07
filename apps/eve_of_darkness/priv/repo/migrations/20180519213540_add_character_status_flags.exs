defmodule EOD.Repo.Migrations.AddCharacterStatusFlags do
  use Ecto.Migration

  def change do
    alter table("characters") do
      add :cloak_hood_up,      :boolean, default: true
      add :helmet_visible,     :boolean, default: true
      add :cloak_visible,      :boolean, default: true
      add :active_quiver_slot, :integer, default: 0
      add :active_weapon,      :integer, default: 0xF
    end
  end
end
