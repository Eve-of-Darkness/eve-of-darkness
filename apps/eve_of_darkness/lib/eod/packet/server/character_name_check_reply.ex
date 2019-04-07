defmodule EOD.Packet.Server.CharacterNameCheckReply do
  @moduledoc """
  This packet is sent in response to a character name check request
  and lets the client know if the name is valid, invalid, or a duplicate.
  Client side this either shows something like "This name is not valid" or
  "This name has already been taken" for the non-valid flags.

  See:
    * `EOD.Packet.Client.CharacterNameCheckRequest`
  """
  use EOD.Packet do
    code(0xCC)

    field(:character_name, :c_string, size: [bytes: 30])
    field(:username, :c_string, size: [bytes: 24])

    enum :status, :integer, size: [bytes: 1], default: 0 do
      0 -> :valid
      1 -> :invalid
      2 -> :duplicate
    end

    blank(using: 0x00, size: [bytes: 3])
  end
end
