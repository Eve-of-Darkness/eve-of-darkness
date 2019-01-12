defmodule EOD.Socket.TCP.GameSocket do
  @moduledoc """
  This is the wrapper around a :gen_tcp socket.  It has a protocol
  implementation for `EOD.Socket` and performs automatic encoding and
  decoding of messages to help hide away the network level details
  of the packets being used.
  """
  alias EOD.Socket.TCP

  defstruct socket: nil

  @doc """
  Requires a :gen_tcp socket
  """
  def new(socket) when is_port(socket), do: %__MODULE__{socket: socket}

  def send(%{socket: socket}, %TCP.ServerPacket{} = data) do
    with {:ok, io_list} <- TCP.ServerPacket.to_iolist(data),
         do: :gen_tcp.send(socket, io_list)
  end

  def send(socket, data) when is_map(data) do
    with {:ok, data} <- TCP.Encoding.encode(data),
         do: __MODULE__.send(socket, data)
  end

  def send(_, _), do: {:error, :not_tcp_server_packet}

  def recv(%{socket: socket}) do
    with {:ok, data} <- :gen_tcp.recv(socket, 0),
         {:ok, packet} <- TCP.ClientPacket.from_binary(data) do
      TCP.Encoding.decode(packet)
    else
      {:error, error} ->
        {:error, error}

      {:partial, bin, remaining} ->
        with {:ok, packet} = fill(socket, bin, remaining) do
          TCP.Encoding.decode(packet)
        end
    end
  end

  def close(%{socket: socket}), do: :gen_tcp.close(socket)

  defp fill(socket, bin, remaining) do
    with {:ok, data} <- :gen_tcp.recv(socket, remaining) do
      data_size = byte_size(data)

      cond do
        data_size == remaining ->
          TCP.ClientPacket.from_binary(bin <> data)

        data_size < remaining ->
          fill(socket, bin <> data, remaining - data_size)

        data_size > remaining ->
          {:error, :tcp_stream_overflow}
      end
    end
  end
end

defimpl EOD.Socket, for: EOD.Socket.TCP.GameSocket do
  def send(socket, data), do: EOD.Socket.TCP.GameSocket.send(socket, data)
  def recv(socket), do: EOD.Socket.TCP.GameSocket.recv(socket)
  def close(socket), do: EOD.Socket.TCP.GameSocket.close(socket)
end
