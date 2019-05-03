defmodule EOD.Web.Plug.CurrentUser do
  @moduledoc """
  Simple plug that sets `current_user` on a connection if one is available.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    conn
    |> assign(:current_user, Guardian.Plug.current_resource(conn))
  end
end
