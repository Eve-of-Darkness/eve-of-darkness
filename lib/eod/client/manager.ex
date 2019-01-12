defmodule EOD.Client.Manager do
  @moduledoc """
  Handles bootstrapping incomming socket connections and keeps track of
  clients started with it.
  """
  use GenServer
  alias EOD.Client

  defstruct clients: nil,
            sessions: nil

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  @doc """
  Starts a client with a socket and optionaly specified server.  If the server
  is not given as an option it defaults to the calling process as the server.
  """
  def start_client(manager, tcp_socket, opts \\ []) do
    server = Keyword.get(opts, :server, self())
    GenServer.cast(manager, {:start_client, tcp_socket, server})
  end

  @doc """
  Returns the number of clients that are currently running and being
  supervised the client manager
  """
  def client_count(manager), do: GenServer.call(manager, :client_count)

  # GenServer Callbacks

  def init(_) do
    with {:ok, clients} <- client_supervisor(),
         {:ok, sessions} <- Client.SessionManager.start_link() do
      {:ok, %__MODULE__{clients: clients, sessions: sessions}}
    end
  end

  def handle_call(:client_count, _, state) do
    %{workers: count} = Supervisor.count_children(state.clients)
    {:reply, count, state}
  end

  def handle_cast({:start_client, socket, server}, state) do
    {:ok, _client} =
      Supervisor.start_child(
        state.clients,
        [%Client{tcp_socket: socket, sessions: state.sessions, server: server}]
      )

    {:noreply, state}
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
