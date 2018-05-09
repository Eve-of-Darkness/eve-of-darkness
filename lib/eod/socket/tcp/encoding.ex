defmodule EOD.Socket.TCP.Encoding do
  @moduledoc """
  Handles the encoding and decoding of messages for TCP.  Used
  directly by `EOD.Socket.TCP.GameSocket`
  """
  alias EOD.Socket.TCP.ClientPacket
  alias EOD.Socket.TCP.ServerPacket
  alias EOD.Packet.{Client, Server}
  require Logger

  @client_packets [
    Client.AcknowledgeSession,
    Client.CharacterCrudRequest,
    Client.CharacterNameCheckRequest,
    Client.CharacterOverviewRequest,
    Client.CharacterSelectRequest,
    Client.ClosingConnection,
    Client.GameOpenRequest,
    Client.HandShakeRequest,
    Client.LoginRequest,
    Client.PingRequest,
    Client.RegionRequest,
    Client.WorldInitRequest
  ]

  @doc """
  Given an `EOD.Socket.TCP.ClientPacket`, this will decode
  the packet into map with the `:id` describing what kind of
  message it is in this format: `{:ok, packet=%{id: message_id}}`.
  It can also fail with `{:error, reason}`.
  """
  for c_packet <- @client_packets do
    code = apply(c_packet, :code, [])
    id = apply(c_packet, :packet_id, [])

    def decode(%ClientPacket{id: unquote(code)} = packet) do
      with {:ok, data} <- unquote(c_packet).from_binary(packet.data) do
        {:ok, %{packet | data: data, id: unquote(id)}}
      end
    end
  end

  def decode(packet) do
    Logger.warn("Unknown TCP Packet: #{inspect(packet)}")
    {:error, :unknown_tcp_packet}
  end

  @server_packets [
    Server.AssignSession,
    Server.CharacterNameCheckReply,
    Server.CharacterOverviewResponse,
    Server.CharacterPointsUpdate,
    Server.CharacterStatusUpdate,
    Server.GameOpenReply,
    Server.HandshakeResponse,
    Server.LoginDenied,
    Server.LoginGranted,
    Server.PingReply,
    Server.Realm,
    Server.RegionReply,
    Server.SelfLocationInformation
  ]

  @doc """
  Encodes a map message with a known id message to tcp server
  packet that is ready to be sent to the client.  On success
  it returns `{:ok, packet}` and failure `{:error, reason}`
  """
  for s_packet <- @server_packets do
    code = apply(s_packet, :code, [])

    def encode(%unquote(s_packet){} = packet) do
      with {:ok, bin} <- unquote(s_packet).to_binary(packet) do
        {:ok, %ServerPacket{code: unquote(code), data: [bin]}}
      end
    end
  end

  def encode(packet) do
    Logger.warn("Unknown Message to encode for TCP: #{inspect(packet)}")
    {:error, :unknown_tcp_message}
  end
end
