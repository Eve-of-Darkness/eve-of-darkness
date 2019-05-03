defmodule EOD.Client do
  @moduledoc """
  Serves as a logical representation of the client's connection to the server.
  It's responsibility is to hold state and handle back and forth requests from
  it and the rest of the system.
  """
  use GenServer
  alias EOD.Client
  require Logger

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

  def handle_call({:share_test_transaction, pid}, _, state) do
    Ecto.Adapters.SQL.Sandbox.allow(EOD.Repo, pid, self())
    {:reply, :ok, state}
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  def handle_info({{:game_packet, ref}, packet}, %{ref: ref} = state) do
    require Client.LoginPacketHandler
    require Client.CharacterSelectPacketHandler
    require Client.ConnectivityPacketHandler
    require Client.LoadPlayerPacketHandler

    updated =
      case packet.id do
        id when id in Client.LoginPacketHandler.handles() ->
          Client.LoginPacketHandler.handle_packet(state, packet)

        id when id in Client.ConnectivityPacketHandler.handles() ->
          Client.ConnectivityPacketHandler.handle_packet(state, packet)

        id when id in Client.CharacterSelectPacketHandler.handles() ->
          Client.CharacterSelectPacketHandler.handle_packet(state, packet)

        id when id in Client.LoadPlayerPacketHandler.handles() ->
          Client.LoadPlayerPacketHandler.handle_packet(state, packet)

        _ ->
          state
      end

    {:noreply, updated}
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
