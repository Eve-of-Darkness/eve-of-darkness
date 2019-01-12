defmodule EOD.Packet.Server.LoginGranted do
  @moduledoc """
  This is the packet sent to the client on successful login to the server,
  echoing back there user name, the name and id of the server, and a color
  flag which tells the client how to handle the coloring of text above players
  names.  This coloring flag also appears to effect how the "select nearest"
  buttons work as well.

  See:
    * `EOD.Packet.Client.LoginRequest`
  """
  use EOD.Packet do
    code(0x2A)

    field(:username, :pascal_string, size: [bytes: 1])
    field(:server_name, :pascal_string, size: [bytes: 1])
    field(:server_id, :integer, size: [bytes: 1], default: 5)

    # TODO: values are best guess, need testing and verification
    enum :client_coloring, :integer, size: [bytes: 1], default: 7 do
      0 -> :standard
      1 -> :standard_pvp
      3 -> :standard_pve
      7 -> :standard_all_realm
    end

    blank(using: 0x00, size: [bytes: 2])
  end
end
