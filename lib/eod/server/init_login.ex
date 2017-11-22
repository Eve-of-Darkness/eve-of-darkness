defmodule EOD.Server.InitLogin do
  @moduledoc """
  Handles fresh TCP sockets in parallel and performs the initial client
  registration and login process.
  """
  use GenServer
  alias EOD.Socket
  require Logger

  defstruct login_supervisor: nil

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{})
  end

  def handle_socket(pid, socket=%Socket{}) do
    GenServer.cast(pid, {:handle_socket, socket})
  end

  # GenServer Callbacks

  def init(state) do
    {:ok, supervisor} = Task.Supervisor.start_link()
    {:ok, %{ state | login_supervisor: supervisor }}
  end

  def handle_cast({:handle_socket, socket}, state) do
    Task.Supervisor.start_child(state.login_supervisor,
                                fn -> login(socket, state) end)
    {:noreply, state}
  end

  defp login(socket, _state) do
    case Socket.recv(socket) do
      # This happens quite a bit from `zero` pings from the portal
      # checking to see if the server is available
      {:error, :closed} ->
        Logger.debug "Connection closed sending nothing"

      {:ok, packet} ->
        Logger.debug """
        Login Attempt:
        #{inspect packet}
        """
    end
  end
end
