defmodule EOD.Player.LocationInformation do
  @moduledoc """
  This module manages the location information for a character and is also responsible for
  notifying other systems of changes that happen.
  """

  alias EOD.Player
  alias __MODULE__, as: LocationInformation

  defstruct x_loc: 0.0,
            y_loc: 0.0,
            z_loc: 0.0,
            heading: 0,
            region: 0

  def init(%Player{character: char} = player) do
    loc_info = %LocationInformation{
      x_loc: char.x_loc,
      y_loc: char.y_loc,
      z_loc: char.z_loc,
      region: char.region,
      heading: char.heading
    }

    {:ok, put_in(player.data[:loc_info], loc_info)}
  end
end
