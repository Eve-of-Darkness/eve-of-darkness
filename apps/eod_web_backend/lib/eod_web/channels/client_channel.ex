defmodule EOD.Web.ClientChannel do
  @moduledoc """
  This is responsible for interacting with the game clients as well
  as getting general information on the clients from the game server

  See Also: `EOD.Web.ClientController`
  """

  use Phoenix.Channel
  alias EOD.Client.Manager
  alias EOD.Server, as: GameServer

  def join("clients", _payload, socket) do
    # TODO: This is a crude timer update; should be a sub
    # to the manager somehow in a refactor
    Process.send_after(self(), :maybe_update_count, 1)
    {:ok, socket}
  end

  def handle_info(:maybe_update_count, socket) do
    count =
      GameServer
      |> EOD.Server.client_manager()
      |> Manager.client_count()

    socket |> push("client_count", %{total: count})

    Process.send_after(self(), :maybe_update_count, 1000)

    {:noreply, socket}
  end
end
