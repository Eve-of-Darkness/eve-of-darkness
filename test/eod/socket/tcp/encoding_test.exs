defmodule EOD.Socket.TCP.EncodingTest do
  use ExUnit.Case, async: true
  alias EOD.Socket.TCP.ClientPacket, as: CP
  alias EOD.Socket.TCP.ServerPacket, as: SP
  alias EOD.Socket.TCP.Encoding
  alias EOD.Packet.Client.HandShakeRequest
  alias EOD.Packet.Server.HandshakeResponse

  test ":handshake_request" do
    expected = %CP{
      id: :handshake_request,
      data: %HandShakeRequest{
        addons: 3,
        build: 9479,
        major: 1,
        minor: 1,
        patch: 24,
        rev: 97,
        type: 6
      }
    }

    assert {:ok, expected} ==
             %CP{id: 0xF4, data: <<0x36, 0x01, 0x01, 0x18, 0x61, 0x25, 0x07>>}
             |> Encoding.decode()
  end

  test ":handshake_response" do
    handshake_resp = %HandshakeResponse{type: 6, version: "1.124"}
    {:ok, bin} = HandshakeResponse.to_binary(handshake_resp)

    expected = {:ok, %SP{code: 0x22, data: [bin]}}
    assert expected == Encoding.encode(handshake_resp)
  end
end
