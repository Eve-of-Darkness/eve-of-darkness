defmodule EOD.Region do
  @moduledoc """
  Each area that you can "load" into with the client is a region.
  """

  use GenServer
  alias EOD.Repo.RegionData

  defstruct data: %RegionData{},
            ip_address: "0.0.0.0",
            tcp_port: 10_300

  def start_link(%RegionData{} = data, opts \\ []) do
    ip = Keyword.get(opts, :ip_address, "0.0.0.0")
    port = Keyword.get(opts, :tcp_port, 10_300)

    GenServer.start_link(
      __MODULE__,
      %__MODULE__{data: data, ip_address: ip, tcp_port: port},
      opts
    )
  end

  def region_id(pid), do: GenServer.call(pid, :region_id)

  def get_data(pid), do: GenServer.call(pid, :get_data)

  def get_overview(pid), do: GenServer.call(pid, :get_overview)

  # GenServer Callbacks

  def init(args) do
    {:ok, args}
  end

  def handle_call(:region_id, _, state) do
    {:reply, state.data.region_id, state}
  end

  def handle_call(:get_data, _, state) do
    {:reply, state.data, state}
  end

  def handle_call(:get_overview, _, state) do
    oveview = %{
      region_id: state.data.region_id,
      name: state.data.name,
      ip_address: state.ip_address,
      tcp_port: state.tcp_port
    }

    {:reply, oveview, state}
  end
end
