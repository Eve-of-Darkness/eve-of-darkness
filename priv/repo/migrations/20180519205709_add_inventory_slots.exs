defmodule EOD.Repo.Migrations.AddInventorySlots do
  use Ecto.Migration

  def change do
    create table(:inventory_slots, primary_key: false) do
      add :id,            :uuid,    primary_key: true
      add :character_id,  :uuid
      add :slot_position, :integer
      add :level,         :integer
      add :color,         :integer
      add :emblem,        :integer
      add :dps,           :integer
      add :af,            :integer
      add :speed,         :integer
      add :abs,           :integer
      add :damage_type,   :integer
      add :weight,        :integer
      add :condition,     :integer
      add :durability,    :integer
      add :quality,       :integer
      add :bonus,         :integer
      add :model,         :integer
      add :extension,     :integer
      add :name,          :string
      add :count,         :integer
      add :effect,        :integer

      # TODO: This flag will eventually be broken
      # out into seperate flags as understanding
      # of it evolves
      add :magic_flag,    :integer
    end

    create unique_index(:inventory_slots, [:character_id, :slot_position])
  end
end
