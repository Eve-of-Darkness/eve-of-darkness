defmodule EOD.Client.Manager do
  @moduledoc """
  Handles bootstrapping incomming socket connections and keeps track of
  clients started with it.
  """
  use GenServer
  alias EOD.Client

  defstruct client_super: nil

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def start_client(manager, tcp_socket) do
    GenServer.cast(manager, {:start_client, tcp_socket})
  end

  # GenServer Callbacks

  def init(_) do
    with {:ok, supervisor} <- client_supervisor()
    do
      {:ok, %__MODULE__{client_super: supervisor}}
    end
  end

  def handle_cast({:start_client, socket}, state) do
    {:ok, _client} =
      Supervisor.start_child(
        state.client_super,
        [%Client{tcp_socket: socket}]
      )
    {:noreply, state}
  end

  defp client_supervisor do
    alias EOD.Client
    spec = Supervisor.child_spec(Client, start: {Client, :start_link, []})
    Supervisor.start_link([spec], strategy: :simple_one_for_one)
  end
end
