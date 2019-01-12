defmodule EOD.Packet.Client.CharacterNameCheckRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.CharacterNameCheckRequest, as: NameCheck

  test "it works like a struct" do
    req = %NameCheck{}
    assert req.character_name == ""
    assert req.username == ""
  end

  test "it can create a binary" do
    {:ok, bin} =
      %NameCheck{character_name: "cheesepicklesonions", username: "ben"}
      |> NameCheck.to_binary()

    assert bin == pad("cheesepicklesonions", 30) <> pad("ben", 24) <> <<0, 0, 0, 0>>
  end

  test "it can be created from a binary" do
    binary = pad("milo", 30) <> pad("ben", 24) <> <<1, 1, 3, 45>>
    {:ok, req} = NameCheck.from_binary(binary)
    assert req.username == "ben"
    assert req.character_name == "milo"
  end

  test "it's packet size is 58" do
    assert NameCheck.packet_size() == 58
  end

  defp pad(string, amount), do: String.pad_trailing(string, amount, <<0>>)
end
