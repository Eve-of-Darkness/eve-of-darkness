defmodule EOD do
  @moduledoc false
  use Application

  @base_services [
    EOD.Repo,
    {Registry, keys: :unique, name: EOD.Server.Registry},
    {Registry, keys: :unique, name: EOD.Client.Registry},
    {Registry, keys: :unique, name: EOD.Region.Registry}
  ]

  def start(_type, _args) do
    opts = [strategy: :rest_for_one, name: EOD.Supervisor]
    children = services(Mix.env())
    Supervisor.start_link(children, opts)
  end

  defp services(:test), do: @base_services
  defp services(_), do: @base_services ++ [EOD.Server]
end
