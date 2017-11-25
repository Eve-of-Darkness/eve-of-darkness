defmodule EOD.Socket.TCP.GameSocket do
  @moduledoc """
  This is the wrapper around a :gen_tcp socket.  It has a protocol
  implementation for `EOD.Socket` and performs automatic encoding and
  decoding of messages to help hide away the network level details
  of the packets being used.
  """
  defstruct socket: nil

  @doc """
  Requires a :gen_tcp socket
  """
  def new(socket) when is_port(socket), do: %__MODULE__{socket: socket}
end

defimpl EOD.Socket, for: EOD.Socket.TCP.GameSocket do
  alias EOD.Socket.TCP

  def send(%{socket: socket}, data=%TCP.ServerPacket{}) do
    with {:ok, io_list} <- TCP.ServerPacket.to_iolist(data),
    do: :gen_tcp.send(socket, io_list)
  end
  def send(socket, data) when is_map(data) do
    with {:ok, data} <- TCP.Encoding.encode(data),
    do: __MODULE__.send(socket, data)
  end
  def send(_, _), do: {:error, :not_tcp_server_packet}

  def recv(%{socket: socket}) do
    with \
      {:ok, data} <- :gen_tcp.recv(socket, 0),
      {:ok, packet} <- TCP.ClientPacket.from_binary(data),
    do: TCP.Encoding.decode(packet)
  end

  def close(%{socket: socket}), do: :gen_tcp.close(socket)
end
