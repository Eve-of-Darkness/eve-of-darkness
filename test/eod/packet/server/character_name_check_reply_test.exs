defmodule EOD.Packet.Server.CharacterNameCheckReplyTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.CharacterNameCheckReply, as: NameCheck

  test "it works as a struct" do
    req = %NameCheck{}
    assert req.character_name == ""
    assert req.username == ""
    assert req.status == :valid
  end

  test "it can create a binary" do
    {:ok, bin} =
      %NameCheck{character_name: "piggly", username: "wiggly", status: :invalid}
      |> NameCheck.to_binary

    assert bin == pad("piggly", 30) <> pad("wiggly", 24) <> <<1, 0, 0, 0>>
  end

  test "it can be created from a binary" do
    bin = pad("thebigb", 30) <> pad("ben", 24) <> <<2, 0, 0, 0>>
    {:ok, req} = NameCheck.from_binary(bin)

    assert req.username == "ben"
    assert req.character_name == "thebigb"
    assert req.status == :duplicate
  end

  test "it's size matches it's bit size" do
    {:ok, bin} = %NameCheck{} |> NameCheck.to_binary
    assert byte_size(bin) == NameCheck.packet_size
  end

  defp pad(string, amount), do: String.pad_trailing(string, amount, <<0>>)
end
