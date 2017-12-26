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
            client_coloring: :standard_all_realm,
            regions: []

  def new do
    %Settings{
      regions: all_enabled_regions(),
      tcp_address: first_valid_ip()
    }
  end

  defp all_enabled_regions do
    EOD.Repo.RegionData.enabled |> EOD.Repo.all
  end

  defp first_valid_ip() do
    {:ok, addresses} = :inet.getif

    {{ip1, ip2, ip3, ip4}, _, _} =
      Enum.find(addresses, fn
                   {_, {0, 0, 0, 0}, _} -> false
                   {_, _, _} -> true
      end) || {{0, 0, 0, 0}, nil, nil}

    "#{ip1}.#{ip2}.#{ip3}.#{ip4}"
  end
end
