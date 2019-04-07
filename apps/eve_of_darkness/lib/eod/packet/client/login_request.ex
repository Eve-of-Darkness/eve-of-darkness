defmodule EOD.Packet.Client.LoginRequest do
  @moduledoc """
  After the handshake between the client and server have taken place
  the client sends this login request to gain access to the server.
  The first seven bytes are ignored; but for the curious they are
  the exact same fields that are found in the handshake request.

  See:
    * `EOD.Packet.Client.HandShakeRequest`
    * `EOD.Packet.Server.HandShakeResponse`
  """
  use EOD.Packet do
    code(0xA7)
    id(:login_request)

    blank(using: 0x00, size: [bytes: 7])
    field(:username, :pascal_string, type: :little, size: 2)
    field(:password, :pascal_string, type: :little, size: 2)
  end
end
