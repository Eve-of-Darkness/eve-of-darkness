defmodule EOD.Packet.Client.HandShakeRequest do
  @moduledoc """
  This is the first packet that is sent by the the client and kicks
  off the process of connecting to the server.

  See:
    * `EOD.Packet.Server.HandshakeResponse`
  """
  use EOD.Packet do
    code 0xF4

    field :addons, :integer, size: [bits: 4]
    field :type,   :integer, size: [bits: 4]
    field :major,  :integer, size: [bytes: 1]
    field :minor,  :integer, size: [bytes: 1]
    field :patch,  :integer, size: [bytes: 1]
    field :rev,    :integer, size: [bytes: 1]
    field :build,  :integer, size: [bytes: 2]
  end
end
