defmodule EOD.Socket.TCP.Encoding do
  @moduledoc """
  Handles the encoding and decoding of messages for TCP.  Used
  directly by `EOD.Socket.TCP.GameSocket`
  """
  alias EOD.Socket.TCP.Encoding
  alias EOD.Socket.TCP.ClientPacket, as: Packet
  require Logger

  @decoders %{
    handshake_request: { 0xF4, Encoding.HandshakeRequest },
    login_request: { 0xA7, Encoding.LoginRequest }
  }

  @doc """
  Given an `EOD.Socket.TCP.ClientPacket`, this will decode
  the packet into map with the `:id` describing what kind of
  message it is in this format: `{:ok, packet=%{id: message_id}}`.
  It can also fail with `{:error, reason}`.
  """
  for {id, {code, decoder}} <- @decoders do
    def decode(%Packet{id: unquote(code)}=packet),
      do: unquote(decoder).decode(packet, unquote(id))
  end
  def decode(packet) do
    Logger.warn "Unknown TCP Packet: #{inspect packet}"
    {:error, :unknown_tcp_packet}
  end

  @encoders %{
    handshake_response: { 0x22, Encoding.HandshakeResponse },
    login_granted: { 0x2A, Encoding.LoginGranted },
    login_denied: { 0x2C, Encoding.LoginDenied }
  }

  @doc """
  Encodes a map message with a known id message to tcp server
  packet that is ready to be sent to the client.  On success
  it returns `{:ok, packet}` and failure `{:error, reason}`
  """
  for {id, {code, encoder}} <- @encoders do
    def encode(%{id: unquote(id)}=packet),
      do: unquote(encoder).encode(unquote(code), packet)
  end
  def encode(packet) do
    Logger.warn "Unknown Message to encode for TCP: #{inspect packet}"
    {:error, :unknown_tcp_message}
  end
end
