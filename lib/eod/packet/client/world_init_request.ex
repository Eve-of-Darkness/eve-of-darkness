defmodule EOD.Packet.Client.WorldInitRequest do
  @moduledoc """
  This is sent as part of the process of loading into the game from the
  character select screen of the game.
  """
  use EOD.Packet do
    code(0xD4)
    id(:world_init_request)
    blank(using: 0x00, size: [bytes: 1])
  end
end
