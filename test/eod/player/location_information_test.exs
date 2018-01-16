defmodule EOD.Player.LocationInformationTest do
  use EOD.RepoCase, async: true
  alias EOD.Player.LocationInformation, as: LocInfo
  alias EOD.Player

  setup _ do
    char =
      build(:character,
        x_loc: 38_123.0,
        y_loc: 44_000.0,
        z_loc: 18_912.0,
        region: 27,
        heading: 44
      )

    player = %Player{character: char, client: self()}

    {:ok, state} = LocInfo.init(player)

    {:ok, char: char, player: player, state: state}
  end

  describe "init/1" do
    test "it adds a %LocationInformation{} to player data", context do
      assert %LocInfo{} = context.state.data[:loc_info]
    end

    test "it's location information comes from character data", context do
      loc_info = context.state.data[:loc_info]

      assert loc_info.x_loc == 38_123.0
      assert loc_info.y_loc == 44_000.0
      assert loc_info.z_loc == 18_912.0
      assert loc_info.region == 27
      assert loc_info.heading == 44
    end
  end
end
