defmodule EOD.Packet.Client.GameOpenRequest do
  @moduledoc """
  This packet is sent by the client when it wants to load it's selected
  character into the game world.  It's only data member isn't currently
  used; however, it's being included for future use.  It appears if the
  client hasn't verified it's UDP connectivity this single byte it sends
  will be zero.  I am assuming it's one otherwise.

  See:
    * `EOD.Packet.Server.GameOpenReply`
  """
  use EOD.Packet do
    code(0xBF)
    id(:game_open_request)

    field(:udp_verfied, :integer, size: [bytes: 1])
  end
end
