defmodule EOD.Packet.Client.CharacterCrudRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.CharacterCrudRequest, as: CrudReq
  alias CrudReq.Character

  describe "substructure CharacterCrudRequest.Character" do
    test "it works as a struct" do
      req = %Character{}
      assert req.name == ""
      assert req.custom_mode == 0
      assert req.eye_size == 0
      assert req.lip_size == 0
      assert req.eye_color == 0
      assert req.hair_color == 0
      assert req.face_type == 0
      assert req.hair_style == 0
      assert req.mood_type == 0
      assert req.action == :nothing
      assert req.level == 0
      assert req.class == 0
      assert req.realm == 0
      assert req.race == 0
      assert req.gender == 0
      assert req.model == 0
      assert req.region == 0
      assert req.strength == 0
      assert req.dexterity == 0
      assert req.constitution == 0
      assert req.quickness == 0
      assert req.intelligence == 0
      assert req.piety == 0
      assert req.empathy == 0
      assert req.charisma == 0
    end

    test "it can read from a binary and return the remainder" do
      bin = String.pad_trailing(<<0::32, "cheesepicklesonions">>, 190, <<0>>)
      {:ok, character, rem} = Character.from_binary_substructure(bin)
      assert character.name == "cheesepicklesonions"
      assert byte_size(rem) == 2
    end

    test "it can read from a binary" do
      bin = String.pad_trailing(<<0::32, "cheesepicklesonions">>, 188, <<0>>)
      {:ok, character} = Character.from_binary(bin)
      assert character.name == "cheesepicklesonions"
    end

    test "it can create a binary" do
      {:ok, bin} =
        %Character{name: "bigb", charisma: 200}
        |> Character.to_binary()

      expected = pad(4) <> pad("bigb", 139) <> <<200>> <> pad(44)
      assert bin == expected
    end

    test "it's packet size is 188" do
      assert Character.packet_size() == 188
    end
  end

  describe "CharacterCrudRequest" do
    test "it works as a struct" do
      req = %CrudReq{}
      assert req.username == ""
      assert req.characters == Stream.repeatedly(fn -> %Character{} end) |> Enum.take(10)
    end

    test "it can create a binary" do
      {:ok, bin} = %CrudReq{username: "b-dawg"} |> CrudReq.to_binary()
      assert bin == pad("b-dawg", 24) <> String.duplicate(pad(188), 10)
    end

    test "it can be created from a binary" do
      bin = pad("j-man", 24) <> String.duplicate(pad(188), 9) <> pad(<<0::32, "cheese">>, 188)
      {:ok, req} = CrudReq.from_binary(bin)
      assert req.username == "j-man"
      assert req.characters |> List.last() |> Map.get(:name) == "cheese"
    end

    test "it's packet size is 1904" do
      assert CrudReq.packet_size() == 1904
    end
  end

  defp pad(str \\ "", amount), do: String.pad_trailing(str, amount, <<0>>)
end
