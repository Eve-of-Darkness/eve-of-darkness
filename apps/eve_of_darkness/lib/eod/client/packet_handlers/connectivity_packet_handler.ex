defmodule EOD.Client.ConnectivityPacketHandler do
  @moduledoc """
  This packet handler is responsible for dealing with packets that
  the client sends for maintaining or closing it's connection to
  the server.
  """

  use EOD.Client.PacketHandler
  alias EOD.Packet.Server.{PingReply, RegionReply}
  alias EOD.Region

  handles_packets([
    EOD.Packet.Client.AcknowledgeSession,
    EOD.Packet.Client.ClosingConnection,
    EOD.Packet.Client.PingRequest,
    EOD.Packet.Client.RegionRequest
  ])

  # Override the default handle_packet/2 to send the whole packet
  # to ping_request/2, it needs the sequence from the packet
  def handle_packet(client, %{id: :ping_request} = packet),
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

  @doc """
  """
  def region_request(client, _packet) do
    with {:ok, region} <- selected_character_region(client),
         overview <- Region.get_overview(region) do
      client
      |> send_tcp(%RegionReply{
        id: overview.region_id,
        name: "#{overview.name}",
        port_1: "#{overview.tcp_port}",
        port_2: "#{overview.tcp_port}",
        ip_address: "#{overview.ip_address}"
      })
    end

    client
  end

  defp selected_character_region(%Client{selected_character: :none}) do
    {:error, :no_region}
  end

  defp selected_character_region(%Client{selected_character: char} = client) do
    client
    |> region_manager
    |> Region.Manager.get_region(char.region)
  end
end
