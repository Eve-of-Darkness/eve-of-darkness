defmodule EOD.Packet.Client.CharacterOverviewRequest do
  @moduledoc """
  This packet is sent by the client letting the server know what realm
  screen it is on and is asking for a list of characters to display to
  the user and for which realm.

  See:
  """
  use EOD.Packet do
    code(0xFC)
    id(:char_overview_request)

    enum :realm, :integer, size: [bytes: 1], default: 0x00 do
      0x00 -> :none
      0x01 -> :albion
      0x02 -> :midgard
      0x03 -> :hibernia
    end
  end
end
