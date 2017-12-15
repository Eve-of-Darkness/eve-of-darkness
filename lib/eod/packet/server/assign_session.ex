defmodule EOD.Packet.Server.AssignSession do
  use EOD.Packet do
    code 0x28

    field :session_id, :little_int, size: [bytes: 2]
  end
end
