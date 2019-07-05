defmodule EOD.Client do
  @moduledoc """
  Serves as a logical representation of the client's connection to the server.
  It's responsibility is to hold state and handle back and forth requests from
  it and the rest of the system.
  """
  use GenServer
  alias EOD.Client
  alias EOD.Socket.TCP
  require Logger

  @type t() :: %Client{}

  defstruct tcp_socket: nil,
            tcp_listener: nil,
            version: %{},
            account: nil,
            client: nil,
            server: nil,
            sessions: nil,
            session_id: nil,
            ref: nil,
            state: :unknown,
            selected_realm: :none,
            selected_character: :none,
            player: :none,
            characters: [],
            started_at: DateTime.utc_now()

  def start_link(%__MODULE__{} = init_state) do
    GenServer.start_link(__MODULE__, init_state)
  end

  @doc """
  Sends a message to the remote connected client.  The goal of this is to
  abstract away how it's done, and to where.
  """
  def send_message(pid, message) do
    GenServer.cast(pid, {:send_message, message})
  end

  @doc """
  Returns an internal state snapshot of the client; which may be useful
  for quickly gleaning lots of information on the connected client.
  """
  def get_state(pid), do: GenServer.call(pid, :get_state)

  @doc """
  Only useful in testing, this forces the client to share the same transaction
  sandbox as the calling process.  This will allow any tests which use clients
  to run side-effect free.
  """
  def share_test_transaction(pid) do
    GenServer.call(pid, {:share_test_transaction, self()})
  end

  @doc """
  This adds a subscription to the tcp socket of the client.

  See: EOD.Socket.Inspector
       EOD.Socket.Inspector.Subscription
  """
  def add_packet_subscription(pid, sub) do
    GenServer.cast(pid, {:add_packet_subscription, sub})
  end

  # GenServer Callbacks

  def init(state) do
    {:ok,
     state
     |> Map.put(:client, self())
     |> Map.put(:ref, make_ref())
     |> Map.put(:started_at, DateTime.utc_now())
     |> begin_listener}
  end

  def handle_cast({:send_message, message}, state) do
    state.tcp_socket |> EOD.Socket.send(message)
    {:noreply, state}
  end

  def handle_cast({:add_packet_subscription, subscription}, state) do
    # TODO Once an inspector is added to the socket it never goes away -
    # this will probably grow out of hand if used for more then simple
    # debugging; probably should add some kind of expire to the inspector?
    %{tcp_socket: socket, tcp_listener: listen} = state

    case socket.inspector do
      false ->
        {:ok, inspector} = EOD.Socket.Inspector.start_link()
        {:ok, inspected_socket} = TCP.GameSocket.add_inspector(socket, inspector)
        EOD.Socket.Listener.update_socket(listen, inspected_socket)
        EOD.Socket.Inspector.subscribe(inspector, subscription)
        {:noreply, %{state | tcp_socket: inspected_socket}}

      inspector ->
        EOD.Socket.Inspector.subscribe(inspector, subscription)
        {:noreply, state}
    end
  end

  def handle_call({:share_test_transaction, pid}, _, state) do
    Ecto.Adapters.SQL.Sandbox.allow(EOD.Repo, pid, self())
    {:reply, :ok, state}
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  def handle_info({{:game_packet, ref}, packet}, %{ref: ref} = state) do
    {:noreply, Client.Router.route(state, packet)}
  end

  def handle_info({{:game_packet, ref}, :error, reason}, %{ref: ref} = state) do
    case reason do
      :closed ->
        {:stop, :normal, state}

      reason ->
        Logger.error("Packet Error: #{reason}")
        {:noreply, state}
    end
  end

  defp begin_listener(%{tcp_socket: socket, ref: ref} = state) do
    alias EOD.Socket.Listener
    %{state | tcp_listener: Listener.start_link(socket, wrap: {:game_packet, ref})}
  end
end
