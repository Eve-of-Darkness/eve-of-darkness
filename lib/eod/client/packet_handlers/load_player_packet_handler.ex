defmodule EOD.Client.LoadPlayerPacketHandler do
  @moduledoc """
  This is responsible for handling requests from the client to load up
  a player into the game.
  """
  alias EOD.{Client, Player}
  alias EOD.Packet.Server.GameOpenReply

  use Client.PacketHandler

  handles_packets([
    EOD.Packet.Client.GameOpenRequest,
    EOD.Packet.Client.WorldInitRequest
  ])

  def game_open_request(%Client{} = client, _packet) do
    client
    |> send_tcp(%GameOpenReply{})
    |> init_player
    |> with_player(fn player ->
      player
      |> Player.cast_with(Player.LivingStats, :send_status_update)
      |> Player.cast_with(Player, :send_points_update)
    end)
  end

  def world_init_request(%Client{} = client, _packet) do
    client
    |> with_player(fn player ->
      player |> Player.cast_with(Player.Location, :send_self_location)
    end)
  end

  defp init_player(client) do
    {:ok, player} = Player.start_link(client.selected_character)
    put_in(client.player, player)
  end
end
