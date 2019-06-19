defmodule EOD.Packet.Server.CharacterOverviewResponseTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.CharacterOverviewResponse, as: CharOverview
  alias CharOverview.{Character, Empty}

  @blank_padding <<0::64>>
  @roflcopter %Character{name: "roflcopters", level: 9}

  test "it works as a struct" do
    resp = %CharOverview{}
    assert resp.characters == Stream.repeatedly(fn -> %Empty{} end) |> Enum.take(10)
  end

  test "it can be created from a binary" do
    {:ok, roflcopters} = Character.to_binary(@roflcopter)
    bin = Enum.reduce(1..10, @blank_padding, fn _, acc -> acc <> roflcopters end)
    {:ok, req} = CharOverview.from_binary(bin)
    assert Enum.all?(req.characters, &match?(@roflcopter, &1))
  end

  test "it can create a binary" do
    characters = Stream.repeatedly(fn -> @roflcopter end) |> Enum.take(5)
    blanks = Stream.repeatedly(fn -> %Empty{} end) |> Enum.take(5)
    {:ok, roflbin} = Character.to_binary(@roflcopter)
    {:ok, blankbin} = Empty.to_binary(%Empty{})

    {:ok, bin} =
      %CharOverview{characters: characters ++ blanks}
      |> CharOverview.to_binary()

    rofls = Enum.reduce(1..5, "", fn _, acc -> acc <> roflbin end)
    blanks = Enum.reduce(1..5, "", fn _, acc -> acc <> blankbin end)

    assert <<@blank_padding, rofls::binary, blanks::binary>> == bin
  end
end
