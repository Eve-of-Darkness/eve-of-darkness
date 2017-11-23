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
    case TCP.ServerPacket.to_iolist(data) do
      {:ok, io_list} ->
        :gen_tcp.send(socket, io_list)

      any -> any
    end
  end
  def send(socket, data) when is_map(data) do
    case TCP.Encoding.encode(data) do
      {:ok, data} -> __MODULE__.send(socket, data)

      any -> any
    end
  end
  def send(_, _), do: {:error, :not_tcp_server_packet}

  def recv(%{socket: socket}) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        with {:ok, packet} <- TCP.ClientPacket.from_binary(data),
        do:  TCP.Encoding.decode(packet)
      any -> any
    end
  end

  def close(socket), do: :gen_tcp.close(socket)
end
