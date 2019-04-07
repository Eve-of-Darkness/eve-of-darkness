defmodule EOD.Packet.Server.PlayerSpeed do
  @moduledoc """
  This informs the client of how fast their character can move... if it can turn?
  No idea yet what that is about? # TODO

  Note:  The max is a percentage; which can exceede 100 percent
  """

  use EOD.Packet do
    code(0xB6)

    field(:max, :integer, size: [bytes: 2], default: 100)

    enum :turning_disabled?, :integer, size: [bytes: 1], default: 0 do
      0 -> false
      1 -> true
    end

    # TODO - Not entirely sure whats up here, default so zero so I'm leaving it
    # here for now until this get's figured out
    blank(using: 0x00, size: [bytes: 1])
  end
end
