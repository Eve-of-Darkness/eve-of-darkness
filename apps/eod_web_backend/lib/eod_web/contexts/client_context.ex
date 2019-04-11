defmodule EOD.Web.ClientContext do
  @moduledoc """
  This module is meant to work directly against a gameserver and insulates
  all calls made to it dealing with game clients.
  """

  alias EOD.Client.Manager
  alias EOD.Client.SessionManager
  alias EOD.Server, as: GameServer

  def get_connected_clients(_params \\ %{}) do
    GameServer
    |> EOD.Server.client_manager()
    |> Manager.session_manager()
    |> SessionManager.accounts_registered()
    |> Enum.map(&%{account_name: &1})
  end

  def connected_client_count(server \\ GameServer) do
    server
    |> EOD.Server.client_manager()
    |> Manager.client_count()
  end

  def authenticated_client_count(server \\ GameServer) do
    server
    |> EOD.Server.client_manager()
    |> Manager.session_manager()
    |> SessionManager.registered_accounts_count()
  end
end
