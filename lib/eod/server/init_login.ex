defmodule EOD.Server.InitLogin do
  @moduledoc """
  Handles fresh TCP sockets in parallel and performs the initial client
  registration and login process.
  """
  use GenServer
  alias EOD.Socket
  alias EOD.Repo
  alias EOD.Repo.Account
  require Logger

  defstruct login_supervisor: nil

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{})
  end

  def handle_socket(pid, socket) do
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

  defp login(socket, state) do
    case Socket.recv(socket) do
      {:ok, %{id: :handshake_request}=data} ->
        Logger.debug "Handshake Init, Client: #{inspect(data)}"
        socket |> Socket.send(%{ data | id: :handshake_response})
        login(socket, Map.drop(data, [:id]))

      {:ok, %{id: :login_request}=data} ->
        Logger.debug "Login Request: #{inspect data}"
        case find_or_create_account(data) do
          {:ok, account} ->
            if Account.correct_password?(account, data.password) do
              Logger.debug "Loggin Success: #{inspect account} #{inspect state}"
              :ok = Socket.send(socket, Map.merge(state, %{id: :login_granted, username: data.username}))
              login(socket, state)
            else
              Logger.error "Login Failure: bad password"
              :ok = Socket.send(socket, Map.merge(state, %{id: :login_denied, reason: :wrong_password}))
              login(socket, state)
            end

          {:error, err} ->
            Logger.error "Account Creation Failed: #{inspect err}"
            :ok = Socket.send(socket, Map.merge(state, %{id: :login_denied, reason: :account_invalid}))
            Socket.close(socket)
        end

      {:ok, unexpected} ->
        Logger.warn "Login Received Unexpected Packet: #{inspect unexpected}"
        login(socket, state)

      {:error, :closed} ->
        Logger.debug "Connection closed sending nothing"

      {:error, :unknown_tcp_packet} ->
        Logger.warn "Login got unkown packet"
        login(socket, state)

      {:error, error} ->
        Logger.error "Login Failure: #{error}"
        Socket.close(socket)
    end
  end

  defp find_or_create_account(%{username: name}=data) do
    import Ecto.Query
    uname = String.downcase(name)
    from(a in Account, where: fragment("lower(?)", a.username) == ^uname)
    |> Repo.one
    |> case do
      nil -> Account.new(data) |> Repo.insert
      account -> {:ok, account}
    end
  end
end
