defmodule EOD.Player.Location do
  @moduledoc """
  This module manages the location information for a character and is also responsible for
  notifying other systems of changes that happen.
  """

  alias EOD.Player
  alias EOD.Packet.Server.SelfLocationInformation, as: SelfLocInfo
  alias __MODULE__, as: Location

  defstruct x_loc: 0.0,
            y_loc: 0.0,
            z_loc: 0.0,
            heading: 0,
            region: 0

  def init(%Player{character: char} = player) do
    loc_info = %Location{
      x_loc: char.x_loc,
      y_loc: char.y_loc,
      z_loc: char.z_loc,
      region: char.region,
      heading: char.heading
    }

    {:ok, put_in(player.data[:loc_info], loc_info)}
  end

  def send_self_location(%Player{} = player) do
    loc_info = player.data.loc_info

    EOD.Client.send_message(player.client, %SelfLocInfo{
      x_loc: loc_info.x_loc,
      y_loc: loc_info.y_loc,
      z_loc: loc_info.z_loc,

      # TODO This obviously isn't correct
      object_id: 285,
      heading: loc_info.heading,
      region: loc_info.region
    })

    player
  end
end
