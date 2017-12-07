defmodule EOD.Packet.Server.Realm do
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
