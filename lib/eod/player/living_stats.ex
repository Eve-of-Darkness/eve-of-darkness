defmodule EOD.Player.LivingStats do
  @moduledoc """
  This module manages a characters living stats, that is to say, all stats which
  change as a result of actions while alive, and are:

  * Hit Points (hp)
  * Endurance
  * Concentration
  * Mana

  While not directly related, it also keeps track of `:is_sitting?` as well.

  These are managed by maintaining an `EOD.Packet.Server.CharacterStatusUpdate`
  struct in the `EOD.Player` data map under the key `:living_stats`.  The goal
  of this is to have a constant, ready to send representation of the packet to
  send out while keeping track of these metrics.
  """
  alias EOD.Player

  @living_stats %{
    hp: %{current: :current_hp, max: :max_hp, percent: :hp_percent},
    mana: %{current: :current_mana, max: :max_mana, percent: :mana_percent},
    endurance: %{current: :current_endurance, max: :max_endurance, percent: :endurance_percent},
    concentration: %{
      current: :current_concentration,
      max: :max_concentration,
      percent: :concentration_percent
    }
  }

  @doc """
  This inits a players character with a cache of living stats that can be later
  sent to the client or changed.  Returns `{:ok, player}` with the new data.
  """
  def init(%Player{character: char} = player) do
    living_stats = %EOD.Packet.Server.CharacterStatusUpdate{
      hp_percent: as_percent(char.max_hp, char.current_hp),
      mana_percent: as_percent(char.max_mana, char.current_mana),
      endurance_percent: as_percent(char.max_endurance, char.current_endurance),
      concentration_percent: as_percent(char.max_concentration, char.current_concentration),
      max_mana: char.max_mana || 0,
      max_endurance: char.max_endurance || 0,
      max_concentration: char.max_concentration || 0,
      max_hp: char.max_hp || 0,
      current_hp: char.current_hp || 0,
      current_endurance: char.current_endurance || 0,
      current_mana: char.current_mana || 0,
      current_concentration: char.current_concentration || 0,
      is_sitting?: char.is_sitting?
    }

    {:ok, put_in(player.data[:living_stats], living_stats)}
  end

  @doc """
  This sends a status update to the client to inform it of the current state
  of the characters living stats for a player's character.  It should be noted
  that sending is a side effect and that it returns the player state so that it
  can be chained with other methods.
  """
  def send_status_update(%Player{} = player) do
    EOD.Client.send_message(player.client, player.data.living_stats)
    player
  end

  @doc """
  This updates a character's living stats by a give delta for a player.  This is
  done by providing the player, living stat, and delta.

  The following example removes ten endurance from the player's current character.

  ```elixir
  LivingStats.living_delta_change(player, :endurance, -10)
  ```

  The five available living stats are:

  * :hp
  * :mana
  * :endurance
  * :concentration
  * :is_sitting?

  It should also be noted that the delta for `is_sitting?` is simply a boolean of
  `true` or `false`
  """
  for {stat, keys} <- @living_stats do
    def living_delta_change(%Player{} = player, unquote(stat), delta) do
      stats = player.data.living_stats
      new_amount = stats.unquote(keys.current) + delta

      cond do
        new_amount <= 0 ->
          put_in(
            player.data.living_stats,
            %{stats | unquote(keys.current) => 0, unquote(keys.percent) => 0}
          )

        new_amount >= stats.unquote(keys.max) ->
          put_in(
            player.data.living_stats,
            %{stats | unquote(keys.current) => 100, unquote(keys.percent) => 100}
          )

        true ->
          put_in(
            player.data.living_stats,
            %{
              stats
              | unquote(keys.current) => new_amount,
                unquote(keys.percent) => as_percent(stats.max_hp, new_amount)
            }
          )
      end
    end
  end

  def living_delta_change(%Player{} = player, :is_sitting?, delta)
      when delta in [true, false] do
    put_in(player.data.living_stats.is_sitting?, delta)
  end

  defp as_percent(0, _), do: 0
  defp as_percent(max, _) when is_nil(max), do: 0
  defp as_percent(max, current) when is_nil(current), do: as_percent(max, 0)
  defp as_percent(max, current), do: trunc(current / max * 100)
end
