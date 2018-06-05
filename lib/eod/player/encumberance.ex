defmodule EOD.Player.Encumberance do
  @moduledoc """
  This module manages the encumberance for a character and knows how to
  transmit this information to the client
  """

  alias EOD.Player
  alias EOD.Packet.Server.Encumberance

  def init(%Player{} = player) do
    {:ok, put_in(player.data[:encumberance], %Encumberance{max: 80})}
  end

  def send(%Player{data: data, client: client} = player) do
    EOD.Client.send_message(client, data.encumberance)
    player
  end
end
