defmodule EOD.Packet.Server.HandshakeResponse do
  @moduledoc """
  This is the packet returned by the server which follows
  up the `EOD.Packet.Client.HandShakeRequest` packet sent
  by it.  Something of note: while the client sends it's
  version out in different interger bytes; it expects the
  main part of the version back as a 5 byte string; ie:
  `1.124`
  """
  use EOD.Packet do
    code(0x22)

    field(:type, :integer, size: [bytes: 1])
    blank(using: 0x00, size: [bytes: 1])
    field(:version, :string, size: [bytes: 5])
    field(:rev, :integer, size: [bytes: 1])
    field(:build, :integer, size: [bytes: 2])
  end
end
