defmodule EOD.Packet.Server.CharacterOverviewResponseTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.CharacterOverviewResponse, as: CharOverview
  alias CharOverview.Character

  test "it works as a struct" do
    resp = %CharOverview{}
    assert resp.username == ""
    assert resp.characters == Stream.repeatedly(fn -> %Character{} end) |> Enum.take(10)
  end

  test "it's size is correct" do
    {:ok, bin} = %CharOverview{} |> CharOverview.to_binary
    assert byte_size(bin) == CharOverview.packet_size
    assert CharOverview.packet_size == 24 + (10 * 188) + 94
  end

  test "it can be created from a binary" do
    bin = pad("ben", 24) <> pad(188*9) <> pad(4) <> pad("ben", 184) <> pad(94)
    {:ok, req} = CharOverview.from_binary(bin)
    assert req.username == "ben"
    assert req.characters |> List.last |> Map.get(:name) == "ben"
  end

  test "it can create a binary" do
    characters =
      Stream.repeatedly(fn -> %Character{name: "roflcopters", level: 9} end)
      |> Enum.take(10)

    {:ok, bin} =
      %CharOverview{username: "ben", characters: characters}
      |> CharOverview.to_binary

    remaining = 21 + (10 * 188) + 94
    assert <<"ben", _::bytes-size(remaining)>> = bin
    assert <<_::bytes-size(24), _::bytes-size(4), "roflcopters", _::binary>> = bin
  end

  defp pad(str \\ "", size), do: String.pad_trailing(str, size, <<0>>)
end
