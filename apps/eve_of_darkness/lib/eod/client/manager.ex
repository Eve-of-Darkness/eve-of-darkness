defmodule EOD.Client.Manager do
  @moduledoc """
  Handles bootstrapping incomming socket connections and keeps track of
  clients started with it.
  """
  use GenServer
  alias EOD.Client
  alias Client.SessionManager

  defstruct clients: nil,
            sessions: nil

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, nil)
  end

  @doc """
  Starts a client with a socket and optionaly specified server.  If the server
  is not given as an option it defaults to the calling process as the server.
  """
  def start_client(socket, manager, opts \\ []) do
    server = Keyword.get(opts, :server, self())
    client = GenServer.call(manager, {:start_client, socket, server})
    :ok = EOD.Socket.controlling_process(socket, client)
  end

  @doc """
  Returns the number of clients that are currently running and being
  supervised the client manager
  """
  def client_count(manager), do: GenServer.call(manager, :client_count)

  @doc """
  Returns the session manager process; which is useful to have if you need to
  lookup and interact with connected clients directly
  """
  def session_manager(manager), do: GenServer.call(manager, :get_session_manager)

  # GenServer Callbacks

  def init(_) do
    with {:ok, clients} <- client_supervisor(),
         {:ok, sessions} <- SessionManager.start_link() do
      {:ok, %__MODULE__{clients: clients, sessions: sessions}}
    end
  end

  def handle_call(:get_session_manager, _, state) do
    {:reply, state.sessions, state}
  end

  def handle_call(:client_count, _, state) do
    %{workers: count} = Supervisor.count_children(state.clients)
    {:reply, count, state}
  end

  def handle_call({:start_client, socket, server}, _, state) do
    {:ok, client} =
      Supervisor.start_child(
        state.clients,
        [%Client{tcp_socket: socket, sessions: state.sessions, server: server}]
      )

    {:reply, client, state}
  end

  # Private Functions

  defp client_supervisor do
    alias EOD.Client

    spec =
      Supervisor.child_spec(Client,
        start: {Client, :start_link, []},
        restart: :transient
      )

    Supervisor.start_link([spec], strategy: :simple_one_for_one)
  end
end
