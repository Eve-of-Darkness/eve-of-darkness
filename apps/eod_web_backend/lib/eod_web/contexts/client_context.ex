defmodule EOD.Web.ClientContext do
  @moduledoc """
  This module is meant to work directly against a gameserver and insulates
  all calls made to it dealing with game clients.
  """

  alias EOD.Client
  alias EOD.Client.Manager
  alias EOD.Client.SessionManager
  alias EOD.Server, as: GameServer
  alias EOD.Socket.Inspector

  def get_client_by_account_name(name) do
    session_manager()
    |> SessionManager.client_by_account(name)
    |> case do
      {:ok, pid} ->
        {:ok, %{account_name: name, pid: pid}}

      {:error, error} ->
        {:error, error}
    end
  end

  def get_connected_clients(_) do
    sess = session_manager()
    accounts = SessionManager.accounts_registered(sess)

    sess
    |> SessionManager.clients_by_accounts(accounts)
    |> Enum.reduce([], fn
      {:ok, account, pid}, found ->
        [%{account_name: account, pid: pid} | found]

      {:error, _, _}, found ->
        found
    end)
    |> Enum.reverse()
  end

  def connected_client_count(server \\ GameServer) do
    server
    |> EOD.Server.client_manager()
    |> Manager.client_count()
  end

  def authenticated_client_count(server \\ GameServer) do
    server
    |> session_manager()
    |> SessionManager.registered_accounts_count()
  end

  def subcribe_to_packet_inspection(client_pid) do
    subscription = Inspector.SimpleSubscription.new()
    Client.add_packet_subscription(client_pid, subscription)
  end

  ## Private Functions

  defp session_manager(server \\ GameServer) do
    server
    |> EOD.Server.client_manager()
    |> Manager.session_manager()
  end
end
