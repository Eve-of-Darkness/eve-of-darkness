defmodule EOD.Packet.Server.HandshakeResponse do
  @moduledoc """
  This is the packet returned by the server which follows
  up the `EOD.Packet.Client.HandShakeRequest` packet sent
  by it.  Something of note: while the client sends it's
  version out in different integer bytes; it expects the
  main part of the version back as a little pascal string
  that is null terminated.

  It is unclear what the last two bytes do in this packet
  but they are needed.
  """
  use EOD.Packet do
    code(0x22)

    field(:version, :pascal_string, size: 4, type: :little, null_terminated: true)
    blank(using: 0x00, size: [bytes: 1])
    blank(using: 0x00, size: [bytes: 1])
  end
end
