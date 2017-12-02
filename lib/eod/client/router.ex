defmodule EOD.Client.Router do
  @moduledoc """
  """
  alias EOD.Client

  def route(_, %{id: id}) when id in [:handshake_request, :login_request],
    do: Client.LoginPacketHandler
end
