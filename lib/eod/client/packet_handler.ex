defmodule EOD.Client.PacketHandler do
  @moduledoc """
  It can get quite cumbersome to work with packets that come to the client.
  This module aims to lighten the amount of work needed and provides a set
  of chain-able methods you can use to work with the client as packets come
  in.
  """

  alias EOD.{Client, Socket}

  defmacro __using__(_) do
    quote do
      import EOD.Client.PacketHandler, only: [
        send_tcp: 2,
        disconnect!: 1,
        change_state: 2,
        register_client_session: 1,
        set_account: 2
      ]

      def handle_packet(client, packet=%{id: packet_id}) do
        apply(__MODULE__, packet_id, [client, packet])
      end

      defoverridable [handle_packet: 2]

      alias EOD.Client
    end
  end

  @doc """
  Sends a message to the connected game client via TCP
  """
  def send_tcp(%Client{tcp_socket: socket}=client, msg) do
    Socket.send(socket, msg)
    client
  end

  @doc """
  Disconnects the game client from the process
  """
  def disconnect!(%Client{tcp_socket: socket}=client) do
    :ok = Socket.close(socket)
    client
  end

  @doc """
  Updates the clients state flag and returns
  """
  def change_state(%Client{}=client, state) do
    %{ client | state: state }
  end

  @doc """
  Sets the account for a client
  """
  def set_account(%Client{}=client, %EOD.Repo.Account{}=account) do
    %{ client | account: account }
  end

  @doc """
  Registers a client with the session manager.  Note that this is one of
  the few functions that cannot be chained.  It either returns the updated
  client as `{:ok, client}` or `{:error, error}`.  If the error happens to
  be no sessions available it returns `{:error, :too_many_players_logged_in}`
  """
  def register_client_session(%Client{sessions: sessions}=client) do
    with {:ok, session_id} <- Client.SessionManager.register(sessions) do
      {:ok, %{ client | session_id: session_id }}
    else
      {:error, :no_session} -> {:error, :too_many_players_logged_in}
      any -> any
    end
  end
end
