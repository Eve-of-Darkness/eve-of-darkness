defmodule EOD.Packet.Client.LoginRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.LoginRequest

  test "has a username and password" do
    req = %LoginRequest{}
    assert req.username == ""
    assert req.password == ""
  end

  test "it can create a binary" do
    {:ok, bin} =
      %LoginRequest{username: "bigben", password: "roflcopters"}
      |> LoginRequest.to_binary()

    assert bin == <<0::56, 6, 0, "bigben", 11, 0, "roflcopters">>
  end

  test "it can read from a binary" do
    {:ok, req} =
      <<0::56, 6, 0, "bigben", 11, 0, "roflcopters">>
      |> LoginRequest.from_binary()

    assert req.username == "bigben"
    assert req.password == "roflcopters"
  end

  test "it's size is anchored_dynamic" do
    assert LoginRequest.packet_size() == :anchored_dynamic
  end
end
