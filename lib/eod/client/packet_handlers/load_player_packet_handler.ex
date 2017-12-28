defmodule EOD.Client.LoadPlayerPacketHandler do
  @moduledoc """
  This is responsible for handling requests from the client to load up
  a player into the game.
  """
  alias EOD.{Client, Player}
  alias EOD.Packet.Server.GameOpenReply

  use Client.PacketHandler

  handles_packets [
    EOD.Packet.Client.GameOpenRequest
  ]

  def game_open_request(%Client{} = client, _packet) do
    client
    |> send_tcp(%GameOpenReply{})
    |> init_player
  end

  defp init_player(client) do
    {:ok, player} = Player.start_link(client.selected_character)
    put_in(client.player, player)
  end
end
