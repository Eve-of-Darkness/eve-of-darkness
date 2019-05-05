defmodule EOD.Web.ClientController do
  @moduledoc """
  This is responsible for grabbing state snapshots of clients connected
  to the gameserver and also supports some interactions with them
  """

  use EOD.Web, :controller

  alias EOD.Web.ClientContext

  def index(conn, params) do
    render(conn, "index.json", clients: ClientContext.get_connected_clients(params))
  end

  def show(conn, %{"id" => id}) do
    case ClientContext.get_client_by_account_name(id) do
      {:ok, client} ->
        render(conn, "show.json", client: client)

      {:error, :not_found} ->
        send_resp(conn, 404, "")
    end
  end
end
