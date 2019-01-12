defmodule EOD.Packet.Server.RegionReply do
  @moduledoc """
  This is the information sent back to the client detailing
  the information on which "node" in a server cluster the
  character they are going to load is on.

  See:
    * `EOD.Packet.Client.RegionRequest`
  """
  use EOD.Packet do
    code(0xB1)

    blank(using: 0x00, size: [bytes: 1])
    field(:id, :integer, size: [bytes: 1])
    field(:name, :c_string, size: [bytes: 20])
    field(:port_1, :c_string, size: [bytes: 5])
    field(:port_2, :c_string, size: [bytes: 5])
    field(:ip_address, :c_string, size: [bytes: 20])
  end
end
