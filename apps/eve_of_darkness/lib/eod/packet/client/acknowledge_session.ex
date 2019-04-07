defmodule EOD.Packet.Client.AcknowledgeSession do
  @moduledoc """
  Not entirely sure what this packet is really for.  It doesn't appear
  to have any reply from the server and the client works without a
  reply to this packet.  The client seems to send this in response to
  it's session being set.

  See:
    * `EOD.Packet.Server.AssignSession`
  """
  use EOD.Packet do
    code(0xAC)
    id(:acknowledge_session)

    field(:session_id, :integer, size: [bytes: 2])
    blank(using: 0x00, size: [bytes: 2])
  end
end
