defmodule EOD.Packet.Client.CharacterSelectRequest do
  @moduledoc """
  This packet is sent by the client to identify what character
  is selected by the user.  The first two bytes are somewhat of
  a myster; however, the next 24 bytes hold the characters name.

  A special string of `noname` for the char_name indicates that
  no character is selected.  The rest of the packet is still
  largely unknown but seems to always be the same total size of
  32 bytes.

  It looks like the next two bytes may be the language code of
  the client, but not entirely sure.

  After this packet is sent the client expects to be assigned a
  session id.

  See:
    * `EOD.Packet.Server.AssignSession`
  """
  use EOD.Packet do
    code(0x10)
    id(:char_select_request)

    blank(using: 0x00, size: [bytes: 2])
    field(:char_name, :c_string, size: [bytes: 24])
    blank(using: 0x00, size: [bytes: 6])
  end
end
