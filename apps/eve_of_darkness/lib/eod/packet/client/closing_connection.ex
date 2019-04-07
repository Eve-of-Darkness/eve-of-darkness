defmodule EOD.Packet.Client.ClosingConnection do
  @moduledoc """
  This is the last packet the client will send before releasing it's
  port and shutting down the client.  It's data payload is a single
  byte that always seems to be 0x01.  I'm not fully sure yet if there
  are other values so for now I'm choosing to do nothing with it.
  """
  use EOD.Packet do
    code(0xB8)
    id(:closing_connection)

    field(:reason, :integer, size: [bytes: 1], default: 1)
  end
end
