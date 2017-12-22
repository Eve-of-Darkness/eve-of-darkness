defmodule EOD.Packet.Server.AssignSession do
  @moduledoc """
  Sent to the client to assign a session id to the client.
  """
  use EOD.Packet do
    code 0x28

    field :session_id, :little_int, size: [bytes: 2]
  end
end
