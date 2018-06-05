defmodule EOD.Player.Speed do
  @moduledoc """
  Responsible for determining how "fast" a player is moving and relaying
  that information to the client.
  """

  alias EOD.Player
  alias EOD.Packet.Server.PlayerSpeed

  def init(%Player{} = player) do
    {:ok, put_in(player.data[:speed], %PlayerSpeed{max: 125})}
  end

  def send(%Player{data: data, client: client} = player) do
    EOD.Client.send_message(client, data.speed)
    player
  end
end
