defmodule EOD.Packet.Server.PingReply do
  @moduledoc """
  This is the response the client expects to receive after sending
  a ping request.  It should have the same timestamp as was sent
  by the client as well as it's sequence incremented by one.

  See:
    * `EOD.Packet.Client.PingRequest`
  """
  use EOD.Packet do
    code(0x29)

    field(:timestamp, :integer, size: [bytes: 4])
    blank(using: 0x00, size: [bytes: 4])
    field(:sequence, :integer, size: [bytes: 2])
    blank(using: 0x00, size: [bytes: 6])
  end
end
