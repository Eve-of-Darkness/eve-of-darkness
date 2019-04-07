defmodule EOD.Packet.Client.RegionRequest do
  @moduledoc """
  This is the first packet sent by the client when it is attempting to load
  a character into the world.  It appears nothing is known about this packet
  currently; only that it is this request. It always appears to be 30 bytes
  big.

  TODO: Figure out more with this packet.

  See:
    * `EOD.Packet.Server.RegionReply`
  """
  use EOD.Packet do
    code(0x9D)
    id(:region_request)

    blank(using: 0x00, size: [bytes: 30])
  end
end
