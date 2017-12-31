defmodule EOD.Player.LivingStatsTest do
  use EOD.RepoCase, async: true
  alias EOD.Player.LivingStats
  alias EOD.Player
  alias EOD.Packet.Server.CharacterStatusUpdate

  setup _ do
    char = build(:character,
                 current_hp: 100, max_hp: 100,
                 current_endurance: 100, max_endurance: 100,
                 current_mana: 100, max_mana: 100,
                 current_concentration: 100, max_concentration: 100)

    player = %Player{character: char, client: self()}

    {:ok, state} = LivingStats.init(player)

    {:ok,
      char: char,
      player: player,
      state: state}
  end

  describe "init" do
    test "it adds :living_stats to player data", context do
      assert %CharacterStatusUpdate{} = context.state.data.living_stats
    end

    test "stats should match characters living stats", context do
      stats = context.state.data.living_stats

      assert stats.current_hp == 100
      assert stats.current_mana == 100
      assert stats.current_concentration == 100
      assert stats.current_endurance == 100

      assert stats.max_hp == 100
      assert stats.max_mana == 100
      assert stats.max_concentration == 100
      assert stats.max_endurance == 100

      refute stats.is_sitting?
    end

    test "it should also calculate percentages of living stats", context do
      stats = context.state.data.living_stats

      assert stats.hp_percent == 100
      assert stats.mana_percent == 100
      assert stats.concentration_percent == 100
      assert stats.endurance_percent == 100
    end
  end

  describe "living_delta_change/3" do
    test "hp goes down", context do
      state = LivingStats.living_delta_change(context.state, :hp, -20)
      assert state.data.living_stats.current_hp == 80
      assert state.data.living_stats.hp_percent == 80
    end

    test "hp can't go below zero", context do
      state = LivingStats.living_delta_change(context.state, :hp, -200)
      assert state.data.living_stats.current_hp == 0
      assert state.data.living_stats.hp_percent == 0
    end

    test "hp can't go above cap", context do
      state = LivingStats.living_delta_change(context.state, :hp, 200)
      assert state.data.living_stats.current_hp == 100
      assert state.data.living_stats.hp_percent == 100
    end

    test "mana goes down", context do
      state = LivingStats.living_delta_change(context.state, :mana, -20)
      assert state.data.living_stats.current_mana == 80
      assert state.data.living_stats.mana_percent == 80
    end

    test "mana can't go below zero", context do
      state = LivingStats.living_delta_change(context.state, :mana, -200)
      assert state.data.living_stats.current_mana == 0
      assert state.data.living_stats.mana_percent == 0
    end

    test "mana can't go above cap", context do
      state = LivingStats.living_delta_change(context.state, :mana, 200)
      assert state.data.living_stats.current_mana == 100
      assert state.data.living_stats.mana_percent == 100
    end

    test "concentration goes down", context do
      state = LivingStats.living_delta_change(context.state, :concentration, -20)
      assert state.data.living_stats.current_concentration == 80
      assert state.data.living_stats.concentration_percent == 80
    end

    test "concentration can't go below zero", context do
      state = LivingStats.living_delta_change(context.state, :concentration, -200)
      assert state.data.living_stats.current_concentration == 0
      assert state.data.living_stats.concentration_percent == 0
    end

    test "concentration can't go above cap", context do
      state = LivingStats.living_delta_change(context.state, :concentration, 200)
      assert state.data.living_stats.current_concentration == 100
      assert state.data.living_stats.concentration_percent == 100
    end

    test "endurance goes down", context do
      state = LivingStats.living_delta_change(context.state, :endurance, -20)
      assert state.data.living_stats.current_endurance == 80
      assert state.data.living_stats.endurance_percent == 80
    end

    test "endurance can't go below zero", context do
      state = LivingStats.living_delta_change(context.state, :endurance, -200)
      assert state.data.living_stats.current_endurance == 0
      assert state.data.living_stats.endurance_percent == 0
    end

    test "endurance can't go above cap", context do
      state = LivingStats.living_delta_change(context.state, :endurance, 200)
      assert state.data.living_stats.current_endurance == 100
      assert state.data.living_stats.endurance_percent == 100
    end

    test "you can change the living state of `is_sitting?`", context do
      refute context.state.data.living_stats.is_sitting?
      state = LivingStats.living_delta_change(context.state, :is_sitting?, true)
      assert state.data.living_stats.is_sitting?
    end
  end
end
