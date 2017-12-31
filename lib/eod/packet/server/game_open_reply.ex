defmodule EOD.Packet.Server.GameOpenReply do
  @moduledoc """
  This is the response sent to the client for it's request of opening
  the game.  A single byte is sent and currently it appears to be zero.
  I suspect this is to match the bytes from the request but I'm not
  entirely sure.

  see:
    * `EOD.Packet.Client.GameOpenRequest`
  """
  use EOD.Packet do
    code 0x2D

    blank using: 0x00, size: [bytes: 1]
  end
end
