defmodule EOD.Packet.Server.Realm do
  @moduledoc """
  This packet is sent to the client to inform it which realm
  to show and passed to the client before a character overview.

  See:

  * `EOD.Packet.Server.CharacterOverviewResponse`
  """
  use EOD.Packet do
    code 0xFE

    enum :realm, :integer, size: [bytes: 1], default: 0 do
      0 -> :none
      1 -> :albion
      2 -> :midgard
      3 -> :hibernia
    end
  end
end
