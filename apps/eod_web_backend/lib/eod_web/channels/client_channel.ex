defmodule EOD.Web.ClientChannel do
  @moduledoc """
  This is responsible for interacting with the game clients as well
  as getting general information on the clients from the game server

  See Also: `EOD.Web.ClientController`
  """

  use Phoenix.Channel
  alias EOD.Web.ClientContext

  def join("clients", _payload, socket) do
    # TODO: This is a crude timer update; should be a sub
    # to the manager somehow in a refactor
    Process.send_after(self(), :maybe_update_count, 1)
    {:ok, socket}
  end

  def handle_info(:maybe_update_count, socket) do
    socket
    |> push("client_count", %{total: ClientContext.connected_client_count()})

    socket
    |> push("registered_accounts_count", %{total: ClientContext.authenticated_client_count()})

    Process.send_after(self(), :maybe_update_count, 1000)
    {:noreply, socket}
  end
end
