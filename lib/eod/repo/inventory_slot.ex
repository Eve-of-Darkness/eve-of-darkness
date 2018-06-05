defmodule EOD.Repo.InventorySlot do
  @moduledoc """
  Data store of information reguarding what is in each "slot" of a
  character.  This can be their wearable slots, backpacks, vaults etc.
  """

  use EOD.Repo.Schema

  schema "inventory_slots" do
    field(:slot_position, :integer, default: 0)
    field(:level, :integer, default: 0)
    field(:color, :integer, default: 0)
    field(:emblem, :integer, default: 0)
    field(:dps, :integer, default: 0)
    field(:af, :integer, default: 0)
    field(:speed, :integer, default: 0)
    field(:abs, :integer, default: 0)
    field(:damage_type, :integer, default: 0)
    field(:weight, :integer, default: 0)
    field(:condition, :integer, default: 100)
    field(:durability, :integer, default: 100)
    field(:quality, :integer, default: 100)
    field(:bonus, :integer, default: 100)
    field(:model, :integer, default: 0)
    field(:extension, :integer, default: 0)
    field(:name, :string)
    field(:count, :integer, default: 0)
    field(:effect, :integer, default: 0)

    # TODO: This flag will eventually be broken
    # out into seperate flags as understanding
    # of it evolves
    field(:magic_flag, :integer, default: 0)

    belongs_to(:character, EOD.Repo.Character)
  end
end
