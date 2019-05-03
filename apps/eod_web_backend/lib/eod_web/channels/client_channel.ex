defmodule EOD.Web.ClientChannel do
  @moduledoc """
  This channel is responsible for broadcasting general overal changes happening
  with clients on the gameserver.

  See Also: `EOD.Web.ClientController`
  """

  use Phoenix.Channel
  alias EOD.Web.ClientContext

  def join("clients", _payload, socket) do
    # TODO: This is a crude timer update; should be a sub
    # to the manager somehow in a refactor
    Process.send_after(self(), :maybe_update_counts, 1)

    {:ok,
     socket
     |> assign(:client_count, 0)
     |> assign(:registered_accounts_count, 0)}
  end

  def handle_info(:maybe_update_counts, socket) do
    possibly_updated =
      socket
      |> maybe_update_registered_accounts_count()
      |> maybe_update_client_count()

    Process.send_after(self(), :maybe_update_counts, 1000)
    {:noreply, possibly_updated}
  end

  defp maybe_update_client_count(socket) do
    client_count = ClientContext.connected_client_count()

    if socket.assigns.client_count != client_count do
      push(socket, "client_count", %{total: client_count})
      assign(socket, :client_count, client_count)
    else
      socket
    end
  end

  defp maybe_update_registered_accounts_count(socket) do
    authenticated_client_count = ClientContext.authenticated_client_count()

    if socket.assigns.registered_accounts_count != authenticated_client_count do
      push(socket, "registered_accounts_count", %{total: authenticated_client_count})
      assign(socket, :registered_accounts_count, authenticated_client_count)
    else
      socket
    end
  end
end
