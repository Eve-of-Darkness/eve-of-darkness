defmodule EOD.Packet.Client.CharacterNameCheckRequest do
  @moduledoc """
  This packet is sent by the client that is sent by the client
  to check a characters name before it allows the user to get
  into the actual tinkering with the characters details.

  See:
    * `EOD.Packet.Server.CharacterNameCheckReply`
  """
  use EOD.Packet do
    code 0xCB
    id :character_name_check

    field :character_name, :c_string, size: [bytes: 30]
    field :username,       :c_string, size: [bytes: 24]
    blank                using: 0x00, size: [bytes: 4]
  end
end
