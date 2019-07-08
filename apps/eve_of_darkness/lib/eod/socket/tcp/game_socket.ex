defmodule EOD.Socket.TCP.GameSocket do
  @moduledoc """
  This is the wrapper around a :gen_tcp socket.  It has a protocol
  implementation for `EOD.Socket` and performs automatic encoding and
  decoding of messages to help hide away the network level details
  of the packets being used.
  """
  alias EOD.Socket.TCP
  alias EOD.Socket.Inspector

  defstruct socket: nil, inspector: false

  @doc """
  Requires a :gen_tcp socket
  """
  def new(socket) when is_port(socket), do: %__MODULE__{socket: socket}

  def send(%{socket: socket, inspector: false}, %TCP.ServerPacket{} = data) do
    with {:ok, io_list} <- TCP.ServerPacket.to_iolist(data),
         do: :gen_tcp.send(socket, io_list)
  end

  def send(%{socket: socket, inspector: inspector}, %TCP.ServerPacket{} = data) do
    with {:ok, io_list} <- TCP.ServerPacket.to_iolist(data) do
      Inspector.inspect_send(inspector, %{data: data, raw: io_list})
      :gen_tcp.send(socket, io_list)
    end
  end

  def send(socket, data) when is_map(data) do
    with {:ok, data} <- TCP.Encoding.encode(data),
         do: __MODULE__.send(socket, data)
  end

  def send(_, _), do: {:error, :not_tcp_server_packet}

  def recv(%{socket: socket, inspector: false}) do
    with {:ok, <<size::16>>} <- :gen_tcp.recv(socket, 2),
         {:ok, data} <- :gen_tcp.recv(socket, size + 10),
         {:ok, packet} <- TCP.ClientPacket.from_binary(<<size::16, data::binary>>) do
      TCP.Encoding.decode(packet)
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def recv(%{socket: socket, inspector: inspector}) do
    with {:ok, <<size::16>>} <- :gen_tcp.recv(socket, 2),
         {:ok, data} <- :gen_tcp.recv(socket, size + 10),
         raw_binary <- <<size::16, data::binary>>,
         {:ok, packet} <- TCP.ClientPacket.from_binary(raw_binary),
         {:ok, decoded} <- TCP.Encoding.decode(packet) do
      Inspector.inspect_recv(inspector, %{raw: raw_binary, data: decoded})
      {:ok, decoded}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def close(%{socket: socket}), do: :gen_tcp.close(socket)

  def controlling_process(%{socket: socket}, pid) do
    :gen_tcp.controlling_process(socket, pid)
  end

  def add_inspector(%{inspector: false} = state, inspector) do
    {:ok, %{state | inspector: inspector}}
  end

  def add_inspector(_, _) do
    {:error, :already_inspected}
  end

  def remove_inspector(state), do: %{state | inspector: false}
end

defimpl EOD.Socket, for: EOD.Socket.TCP.GameSocket do
  def send(socket, data), do: EOD.Socket.TCP.GameSocket.send(socket, data)
  def recv(socket), do: EOD.Socket.TCP.GameSocket.recv(socket)
  def close(socket), do: EOD.Socket.TCP.GameSocket.close(socket)

  def controlling_process(socket, pid),
    do: EOD.Socket.TCP.GameSocket.controlling_process(socket, pid)
end
