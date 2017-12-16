defmodule EOD.Packet.Client.PingRequest do
  @moduledoc """
  The client sends these every four seconds.  It expects to receive
  a `PingReply` with an incremented sequence which is found on the
  client packet `sequence` segment.

  See:
    * `EOD.Packet.Server.PingReply`
  """
  use EOD.Packet do
    code 0xA3
    id :ping_request

    blank using: 0x00, size: [bytes: 4]
    field :timestamp, :integer, size: [bytes: 4]
    blank using: 0x00, size: [bytes: 4]
  end
end
