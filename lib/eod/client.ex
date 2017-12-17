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
            session_id: nil,
            selected_realm: :none,
            selected_character: :none,
            characters: []

  def start_link(init_state=%__MODULE__{}) do
    GenServer.start_link(__MODULE__, init_state)
  end

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
      |> begin_listener}
  end

  def handle_call({:share_test_transaction, pid}, _, state) do
    Ecto.Adapters.SQL.Sandbox.allow(EOD.Repo, pid, self())
    {:reply, :ok, state}
  end

  def handle_info({{:game_packet, ref}, packet}, state=%{ref: ref}) do
    require Client.LoginPacketHandler
    require Client.CharacterSelectPacketHandler
    require Client.ConnectivityPacketHandler

    updated =
      case packet.id do
        id when id in Client.LoginPacketHandler.handles ->
          Client.LoginPacketHandler.handle_packet(state, packet)

        id when id in Client.ConnectivityPacketHandler.handles ->
          Client.ConnectivityPacketHandler.handle_packet(state, packet)

        id when id in Client.CharacterSelectPacketHandler.handles ->
          Client.CharacterSelectPacketHandler.handle_packet(state, packet)

        _ ->
          state
      end

    {:noreply, updated}
  end

  def handle_info({{:game_packet, ref}, :error, reason}, state=%{ref: ref}) do
    case reason do
      :closed ->
        {:stop, :normal, state}

      reason ->
        Logger.error "Packet Error: #{reason}"
        {:noreply, state}
    end
  end

  defp begin_listener(state=%{tcp_socket: socket, ref: ref}) do
    alias EOD.Socket.Listener
    %{ state | tcp_listener: Listener.start_link(socket, wrap: {:game_packet, ref})}
  end
end
