defmodule EOD.Socket.TCP.EncodingTest do
  use ExUnit.Case, async: true
  alias EOD.Socket.TCP.ClientPacket, as: CP
  alias EOD.Socket.TCP.ServerPacket, as: SP
  alias EOD.Socket.TCP.Encoding

  test ":handshake_request" do
    expected = %{id: :handshake_request, addons: 3, build: 9479,
                 major: 1, minor: 1, patch: 24, rev: 97, type: 6}

    assert {:ok, expected} ==
      %CP{id: 0xF4, data: <<0x36, 0x01, 0x01, 0x18, 0x61, 0x25, 0x07>>}
      |> Encoding.decode()
  end

  test ":handshake_response" do
    expected = %SP{code: 34, data: [[[[[[], 6], 0], "1.124"], 97], "%\a"]}

    assert {:ok, expected} ==
      %{id: :handshake_response, addons: 3, build: 9479,
      major: 1, minor: 1, patch: 24, rev: 97, type: 6} |> Encoding.encode()
  end

  test ":login_request" do
    expected = %{id: :login_request, password: "pass", username: "user"}

    assert {:ok, expected} ==
      %CP{id: 0xA7, data: <<0x36, 0x01, 0x01, 0x18, 0x62, 0x69, 0x05, 0x04,
                            0x00, 0x75, 0x73, 0x65, 0x72, 0x04, 0x00, 0x70,
                            0x61, 0x73, 0x73>>} |> Encoding.decode()
  end
end
