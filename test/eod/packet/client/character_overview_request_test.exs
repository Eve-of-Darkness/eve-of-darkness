defmodule EOD.Packet.Client.CharacterOverviewRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.CharacterOverviewRequest

  test "it works like a struct" do
    req = %CharacterOverviewRequest{}
    assert req.username == ""
    assert req.realm == :none
  end

  test "it can convert to binary" do
    {:ok, bin} =
      %CharacterOverviewRequest{username: "ben", realm: :albion}
      |> CharacterOverviewRequest.to_binary()

    assert bin == String.pad_trailing("ben-S", 28, <<0>>)
  end

  test "it can convert from a binary" do
    {:ok, req} =
      String.pad_trailing("ben-S", 28, <<0>>)
      |> CharacterOverviewRequest.from_binary()

    assert req.username == "ben"
    assert req.realm == :albion
  end
end
