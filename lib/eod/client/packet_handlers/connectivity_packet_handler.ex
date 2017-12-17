defmodule EOD.Client.ConnectivityPacketHandler do
  @moduledoc """
  This packet handler is responsible for dealing with packets that
  the client sends for maintaining or closing it's connection to
  the server.
  """

  use EOD.Client.PacketHandler
  alias EOD.Packet.Server.{PingReply}

  handles_packets [
    EOD.Packet.Client.AcknowledgeSession,
    EOD.Packet.Client.ClosingConnection,
    EOD.Packet.Client.PingRequest
  ]

  # Override the default handle_packet/2 to send the whole packet
  # to ping_request/2, it needs the sequence from the packet
  def handle_packet(client, %{id: :ping_request}=packet),
    do: ping_request(client, packet)
  def handle_packet(client, packet), do: super(client, packet)

  @doc """
  About every four seconds the client will send a ping request; to
  which a reply is sent.  This echoes back the request's timestamp
  and returns the sequence of the request incremented by one
  """
  def ping_request(client, packet) do
    send_tcp(client, %PingReply{
      timestamp: packet.data.timestamp,
      sequence: packet.sequence + 1
    })
  end

  @doc """
  This isn't really needed as far as I can tell; however, the client
  sends it so it's handled here as a no-op call pretty much
  """
  def acknowledge_session(client, _packet), do: client

  @doc """
  Handle when the client informs the server it's closing it's
  connection.  Currently there isn't much to do besides close the
  connection
  """
  def closing_connection(client, _packet), do: client |> disconnect!
end
