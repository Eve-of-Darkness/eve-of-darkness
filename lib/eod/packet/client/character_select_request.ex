defmodule EOD.Packet.Client.CharacterSelectRequest do
  @moduledoc """
  This packet is sent by the client to identify what character
  is selected by the use.  The first five bytes are somewhat of
  a myster; however, the next 24 bytes hold the characters name.

  A special string of `noname` for the char_name indicates that
  no character is selected.  The rest of the packet is still
  largely unknown but seems to always be the same total size of
  104 bytes.

  After this packet is sent the client expects to be assigned a
  session id.

  See:
    * `EOD.Packet.Server.AssignSession`
  """
  use EOD.Packet do
    code 0x10
    id :char_select_request

    blank using: 0x00, size: [bytes: 5]
    field :char_name,  :c_string,  size: [bytes: 24]
    blank using: 0x00, size: [bytes: 75]
  end
end
