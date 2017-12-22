defmodule EOD.Region do
  @moduledoc """
  Each area that you can "load" into with the client is a region.
  """

  use GenServer
  alias EOD.Repo.RegionData

  defstruct data: %RegionData{}

  def start_link(%RegionData{} = data, opts \\ []) do
    GenServer.start_link(__MODULE__, %__MODULE__{data: data}, opts)
  end

  def region_id(pid), do: GenServer.call(pid, :region_id)

  # GenServer Callbacks

  def handle_call(:region_id, _, state) do
    {:reply, state.data.region_id, state}
  end
end
