defmodule EOD.Player.Encumberance do
  @moduledoc """
  This module manages the encumberance for a character and knows how to
  transmit this information to the client
  """

  use EOD.Player.Data, key: :encumberance
  alias EOD.Player
  alias EOD.Packet.Server.Encumberance

  def init(%Player{}) do
    {:ok, %Encumberance{max: 80}}
  end

  def send(%Player{data: data, client: client} = player) do
    EOD.Client.send_message(client, data.encumberance)
    player
  end
end
