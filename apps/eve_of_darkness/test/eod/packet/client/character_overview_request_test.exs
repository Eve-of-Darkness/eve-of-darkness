defmodule EOD.Packet.Client.CharacterOverviewRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.CharacterOverviewRequest

  test "it works like a struct" do
    req = %CharacterOverviewRequest{}
    assert req.realm == :none
  end

  test "it can convert to binary" do
    {:ok, bin} =
      %CharacterOverviewRequest{realm: :albion}
      |> CharacterOverviewRequest.to_binary()

    assert bin == <<1>>
  end

  test "it can convert from a binary" do
    {:ok, req} = CharacterOverviewRequest.from_binary(<<3>>)

    assert req.realm == :hibernia
  end
end
