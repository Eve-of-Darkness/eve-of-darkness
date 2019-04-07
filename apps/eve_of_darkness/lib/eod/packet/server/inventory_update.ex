defmodule EOD.Packet.Server.InventoryUpdate do
  @moduledoc """
  This is an update packet sent to the client to either populate the initial clients
  loading so it knows what's in it's state or to notify of changes occuring to a
  player's inventory
  """

  require Bitwise

  use EOD.Packet do
    code(0x02)

    structure ItemData do
      field(:slot_number, :integer, size: [bytes: 1], default: 0)
      field(:level, :integer, size: [bytes: 1], default: 1)

      # TODO: These two values appear to be used for a bunch of junk
      # and this will need to be re-tooled later when needed
      # Namely it looks like these flags are also for stack counts
      # and housing item functionality
      field(:dps_af, :integer, size: [bytes: 1], default: 0)
      field(:spd_ab, :integer, size: [bytes: 1], default: 0)

      # TODO Some crazy logic here that makes no sense
      # https://github.com/Eve-of-Darkness/DOLSharp/blob/master/GameServer/packets/Server/PacketLib1109.cs#L7053-L7060
      blank(using: 0x00, size: [bytes: 1])

      field(:damage_type, :integer, size: [bytes: 1], default: 0)

      blank(using: 0x00, size: [bytes: 1])

      field(:weight, :integer, size: [bytes: 2], default: 0)
      field(:condition_percent, :integer, size: [bytes: 1], default: 0)
      field(:durability_percent, :integer, size: [bytes: 1], default: 0)
      field(:quality_percent, :integer, size: [bytes: 1], default: 0)
      field(:bonus_percent, :integer, size: [bytes: 1], default: 0)
      field(:model, :integer, size: [bytes: 2], default: 0)
      field(:extension, :integer, size: [bytes: 1], default: 0)
      field(:emblem_or_color, :integer, size: [bytes: 2], default: 0)

      # TODO Will probably change... this flag is all over the place
      # and drives a potential growing packet for charges and procs ...
      field(:byte_flag, :integer, size: [bytes: 1], default: 0)

      field(:effect, :integer, size: [bytes: 1], default: 0)
      field(:name, :pascal_string, size: [bytes: 1])
    end

    field(:item_count, :integer, size: [bytes: 1], default: 0)
    blank(using: 0x00, size: [bytes: 1])

    compound :item_visibility, :integer, size: [bytes: 1] do
      field(:cloak_visible?, default: true)
      field(:helm_visible?, default: true)
    end

    # TODO This byte can also be an index for house vault number
    # it appears... for now going to ignore that, maybe make a
    # seperate packet for that?
    compound :cloak_and_quiver, :integer, size: [bytes: 1] do
      field(:cloak_hood_up?, default: true)
      field(:active_quiver_slot, default: 0)
    end

    enum :active_weapon, :integer, size: [bytes: 1], default: 0xF do
      0xF -> :none
      0x0 -> :right_hand
      0x1 -> :left_hand
      0x2 -> :two_hand
      0x3 -> :ranged
    end

    enum :window_type, :integer, size: [bytes: 1], default: 0x0 do
      0x0 -> :update
      0x1 -> :equipment
      0x2 -> :inventory
      0x3 -> :player_vault
      0x4 -> :house_vault
      0x5 -> :consign_owner
      0x6 -> :consign_viewer
      0x7 -> :horse_bags
    end

    list(:items, ItemData, size: :dynamic)

    defp compound(:from_binary, :item_visibility, int) do
      %{cloak_visible?: Bitwise.band(int, 1) == 0, helm_visible?: Bitwise.band(int, 2) == 0}
    end

    defp compound(:to_binary, :item_visibility, data) do
      helm = if data.helm_visible?, do: 0, else: 2
      cloak = if data.cloak_visible?, do: 0, else: 1
      Bitwise.bor(helm, cloak)
    end

    defp compound(:from_binary, :cloak_and_quiver, int) do
      %{
        cloak_hood_up?: Bitwise.band(int, 1) == 1,
        active_quiver_slot:
          cond do
            Bitwise.band(int, 16) == 16 -> 1
            Bitwise.band(int, 32) == 32 -> 2
            Bitwise.band(int, 64) == 64 -> 3
            Bitwise.band(int, 128) == 128 -> 4
            true -> 0
          end
      }
    end

    defp compound(:to_binary, :cloak_and_quiver, data) do
      cloak = if data.cloak_hood_up?, do: 1, else: 0

      slot =
        case data.active_quiver_slot do
          0 -> 0
          1 -> 16
          2 -> 32
          3 -> 64
          4 -> 128
        end

      Bitwise.bor(cloak, slot)
    end
  end
end
