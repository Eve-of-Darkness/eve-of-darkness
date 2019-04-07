defmodule EOD.Packet.Server.LoginDeniedTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.LoginDenied

  test "it works as a struct" do
    req = %LoginDenied{}
    assert req.reason == :account_invalid
    assert req.major == 0
    assert req.minor == 0
  end

  test "it can create a binary" do
    {:ok, bin} =
      %LoginDenied{reason: :account_is_banned, major: 1, minor: 1}
      |> LoginDenied.to_binary()

    assert bin == <<0x13, 1, 1, 1, 0, 0>>
  end

  test "it can be created from a binary" do
    {:ok, req} = <<0x05, 1, 2, 18, 0, 0>> |> LoginDenied.from_binary()
    assert req.reason == :client_version_too_low
    assert req.major == 2
    assert req.minor == 18
  end
end
