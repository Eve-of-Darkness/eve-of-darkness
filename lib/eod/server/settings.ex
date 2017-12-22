defmodule EOD.Server.Settings do
  @moduledoc """
  Responsible for holding all of the general settings that a EOD server needs
  to run.  The goal here is to provide some defaults, sanity checking, and
  centralized area to house these values.
  """

  alias __MODULE__, as: Settings

  defstruct tcp_address: "0.0.0.0",
            tcp_port: 10_300,
            server_name: "EOD",
            client_coloring: :standard_all_realm

  def new, do: %Settings{}
end
