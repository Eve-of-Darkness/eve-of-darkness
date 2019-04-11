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
end
