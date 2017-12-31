defmodule EOD.Packet.Server.CharacterStatusUpdateTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.CharacterStatusUpdate, as: CharStatusUpdate

  test "it works as a struct" do
    update = %CharStatusUpdate{}

    assert update.hp_percent == 0
    assert update.mana_percent == 0
    refute update.is_sitting?
    assert update.endurance_percent == 0
    assert update.concentration_percent == 0

    assert update.max_mana == 0
    assert update.max_endurance == 0
    assert update.max_concentration == 0
    assert update.max_hp == 0

    assert update.current_hp == 0
    assert update.current_endurance == 0
    assert update.current_mana == 0
    assert update.current_concentration == 0
  end

  test "it can create a binary" do
    {:ok, bin} =
      %CharStatusUpdate{is_sitting?: true, hp_percent: 100, endurance_percent: 100}
      |> CharStatusUpdate.to_binary

    assert bin == <<100, 0, 2, 100, 0, 0, 0::16, 0::16, 0::16, 0::16,
                    0::16, 0::16, 0::16, 0::16>>
  end

  test "it can be created from a binary" do
    {:ok, msg} =
      <<100, 100, 2, 100, 0, 0, 0::64, 0::64>> |> CharStatusUpdate.from_binary

    assert msg.is_sitting?
    assert msg.hp_percent == 100
    assert msg.mana_percent == 100
    assert msg.endurance_percent == 100
    assert msg.concentration_percent == 0

    assert msg.max_mana == 0
    assert msg.max_endurance == 0
    assert msg.max_concentration == 0
    assert msg.max_hp == 0

    assert msg.current_hp == 0
    assert msg.current_endurance == 0
    assert msg.current_mana == 0
    assert msg.current_concentration == 0
  end
end
