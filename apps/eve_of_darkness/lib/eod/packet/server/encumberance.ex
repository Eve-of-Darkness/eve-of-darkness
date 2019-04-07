defmodule EOD.Packet.Server.Encumberance do
  @moduledoc """
  This packet is sent to notify the client of what there current and
  total encumberance is for their character in game.
  """

  use EOD.Packet do
    code(0xBD)

    field(:max, :integer, size: [bytes: 2])
    field(:current, :integer, size: [bytes: 2])
  end
end
