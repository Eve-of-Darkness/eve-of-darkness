defmodule EOD.Packet.Server.CharacterStatusUpdate do
  @moduledoc """
  This packet is sent to the client to inform the status of the
  character "living" metrics as well as if the character is sitting
  or not.
  """
  use EOD.Packet do
    code(0xAD)

    field(:hp_percent, :integer, size: [bytes: 1])
    field(:mana_percent, :integer, size: [bytes: 1])

    enum :is_sitting?, :integer, size: [bytes: 1] do
      0x00 -> false
      0x02 -> true
    end

    field(:endurance_percent, :integer, size: [bytes: 1])
    field(:concentration_percent, :integer, size: [bytes: 1])

    blank(using: 0x00, size: [bytes: 1])

    field(:max_mana, :integer, size: [bytes: 2])
    field(:max_endurance, :integer, size: [bytes: 2])
    field(:max_concentration, :integer, size: [bytes: 2])
    field(:max_hp, :integer, size: [bytes: 2])

    field(:current_hp, :integer, size: [bytes: 2])
    field(:current_endurance, :integer, size: [bytes: 2])
    field(:current_mana, :integer, size: [bytes: 2])
    field(:current_concentration, :integer, size: [bytes: 2])
  end
end
