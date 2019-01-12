defmodule EOD.TestSocket do
  @moduledoc """
  A bi-directional dummy socket responsible to fill in as a socket system for clients
  to aid in testing without needing to open up an actual TCP port.  The socket has two roles
  to it of `server` and `client`.  The idea is to pass the socket to your test in `server`
  mode and use a `client` role for interaction with your tests.
  """

  defstruct pid: nil, role: :server

  use GenServer

  defmodule State do
    defstruct server_outbox: :queue.new,
              client_outbox: :queue.new,
              waiting_clients: :queue.new,
              waiting_servers: :queue.new,
              state: :open,
              ref: nil
  end

  @empty :queue.new

  @doc """
  Returns a fresh `TestSocket` that can be used with `EOD.Socket`.  It is
  started in `server` mode. The return is `{:ok, socket}`
  """
  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, %State{ref: make_ref()})
    {:ok, %__MODULE__{pid: pid}}
  end

  @doc """
  Receives a message from the point of view of the role you have with the socket.  For
  instance, if you have the role of client it will receive a messages sent to the port
  that is in `server` mode and vise-versa.  On success it returns `{:ok, msg}` or
  `{:error, reason}` on failure.
  """
  def recv(%__MODULE__{pid: pid, role: role}) do
    if Process.alive?(pid) do
      GenServer.call(pid, {:get, role})
    else
      {:error, :closed}
    end
  end

  @doc """
  Similiar to `recv/1` but in reverse. Returns `:ok` on success or `{:error, reasons}`
  on failure.
  """
  def send(%__MODULE__{pid: pid, role: role}, msg) do
    if Process.alive?(pid) do
      GenServer.call(pid, {:send, role, {:ok, msg}})
    else
      {:error, :closed}
    end
  end

  @doc """
  This simulates a port closing and will also stop the underlying process so it
  cannot be used again (similar to a real tcp port).  Returns `:ok`
  """
  def close(%__MODULE__{pid: pid}) do
    if Process.alive?(pid) do
      GenServer.call(pid, :close)
    else
      :ok
    end
  end

  @doc """
  Returns an updated socket with the role set, may be either `:server` or `:client`
  """
  def set_role(socket=%__MODULE__{}=socket, role) when role in [:server, :client] do
    %{ socket | role: role }
  end

  @doc """
  Returns true if the socket has been disconnected.  This is to test w/o having
  to attempt to send or receive data and check for `{:error, :closed}`
  """
  def disconnected?(%__MODULE__{pid: pid}) do
    if Process.alive?(pid) do
      GenServer.call(pid, :disconnected?)
    else
      true
    end
  end

  # GenServer Callbacks

  def init(args) do
    {:ok, args}
  end

  def handle_info({:shutdown, ref}, %{ref: ref}=state) do
    {:stop, :normal, state}
  end

  def handle_call(:disconnected?, _, state) do
    {:reply, state.state == :closed, state}
  end

  def handle_call(:close, _, state) do
    :queue.join(state.waiting_clients, state.waiting_servers)
    |> :queue.to_list
    |> Enum.each(&GenServer.reply(&1, {:error, :closed}))

    {:ok, _} = :timer.send_after(100, {:shutdown, state.ref})

    {:reply, :ok, %{ state | waiting_clients: @empty, waiting_servers: @empty, state: :closed }}
  end

  def handle_call({action, _}, _, %{state: :closed}=state) when action in [:send, :get] do
    {:reply, {:error, :closed}, state}
  end

  def handle_call({:get, :server}, from, %{client_outbox: @empty}=state) do
    waiting = :queue.in(from, state.waiting_servers)
    {:noreply, %{ state | waiting_servers: waiting }}
  end

  def handle_call({:get, :client}, from, %{server_outbox: @empty}=state) do
    waiting = :queue.in(from, state.waiting_clients)
    {:noreply, %{ state | waiting_clients: waiting }}
  end

  def handle_call({:get, :server}, _, %{client_outbox: outbox}=state) do
    {{:value, msg}, updated_outbox} = :queue.out(outbox)
    {:reply, msg, %{ state | client_outbox: updated_outbox }}
  end

  def handle_call({:get, :client}, _, %{server_outbox: outbox}=state) do
    {{:value, msg}, updated_outbox} = :queue.out(outbox)
    {:reply, msg, %{ state | server_outbox: updated_outbox }}
  end

  def handle_call({:send, :server, msg}, _, %{waiting_clients: @empty}=state) do
    messages = :queue.in(msg, state.server_outbox)
    {:reply, :ok, %{ state | server_outbox: messages }}
  end

  def handle_call({:send, :client, msg}, _, %{waiting_servers: @empty}=state) do
    messages = :queue.in(msg, state.client_outbox)
    {:reply, :ok, %{ state | client_outbox: messages }}
  end

  def handle_call({:send, :server, msg}, _, %{waiting_clients: clients}=state) do
    {{:value, client}, remaining_clients} = :queue.out(clients)
    GenServer.reply(client, msg)
    {:reply, :ok, %{ state | waiting_clients: remaining_clients }}
  end

  def handle_call({:send, :client, msg}, _, %{waiting_servers: servers}=state) do
    {{:value, server}, remaining_servers} = :queue.out(servers)
    GenServer.reply(server, msg)
    {:reply, :ok, %{ state | waiting_servers: remaining_servers }}
  end
end

defimpl EOD.Socket, for: EOD.TestSocket do
  def send(socket, msg), do: EOD.TestSocket.send(socket, msg)
  def recv(socket), do: EOD.TestSocket.recv(socket)
  def close(socket), do: EOD.TestSocket.close(socket)
end
