defmodule EOD.Packet.Server.CharacterPointsUpdateTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.CharacterPointsUpdate, as: CharPtsUpdate

  test "it works as a struct" do
    update = %CharPtsUpdate{}
    assert update.realm_points == 0
    assert update.level_progress == 0
    assert update.free_skill_points == 0
    assert update.bounty_points == 0
    assert update.realm_skill_points == 0
    assert update.champion_level_progress == 0
    assert update.experience == 0
    assert update.exp_to_next_lvl == 0
    assert update.champ_exp == 0
    assert update.champ_exp_to_next_lvl == 0
  end

  test "it can create a binary" do
    {:ok, bin} =
      %CharPtsUpdate{realm_points: 150, bounty_points: 5, experience: 30_000}
      |> CharPtsUpdate.to_binary()

    assert bin ==
             <<150::32, 0::16, 0::16, 5::32, 0::16, 0::16, 30_000::little-integer-size(64), 0::64,
               0::64, 0::64>>
  end

  test "it can be created from a binary" do
    {:ok, update} =
      <<150::32, 0::16, 0::16, 5::32, 0::16, 0::16, 30_000::little-integer-size(64), 0::64, 0::64,
        0::64>>
      |> CharPtsUpdate.from_binary()

    assert update.realm_points == 150
    assert update.level_progress == 0
    assert update.free_skill_points == 0
    assert update.bounty_points == 5
    assert update.realm_skill_points == 0
    assert update.champion_level_progress == 0
    assert update.experience == 30_000
    assert update.exp_to_next_lvl == 0
    assert update.champ_exp == 0
    assert update.champ_exp_to_next_lvl == 0
  end
end
