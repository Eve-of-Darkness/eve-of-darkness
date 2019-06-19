defmodule EOD.Packet.Client.CharacterSelectRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.CharacterSelectRequest

  test "it has a char_name" do
    req = %CharacterSelectRequest{}
    assert req.char_name == ""
  end

  test "it can create a binary" do
    {:ok, bin} =
      %CharacterSelectRequest{char_name: "cheesepicklesonions"}
      |> CharacterSelectRequest.to_binary()

    assert bin ==
             <<0, 0, "cheesepicklesonions", 0, 0, 0, 0, 0>> <>
               String.duplicate(<<0>>, 6)
  end

  test "it can create a struct from a binary" do
    {:ok, req} =
      (<<0, 0, "cheesepicklesonions", 0, 0, 0, 0, 0>> <> String.duplicate(<<0>>, 6))
      |> CharacterSelectRequest.from_binary()

    assert req.char_name == "cheesepicklesonions"
  end
end
