defmodule EOD.Region.Manager do
  @moduledoc """
  Responsible for holding the state of a region and orchestrating
  messages to actors in it.
  """
  use GenServer
  alias EOD.Region

  defstruct region_supervisor: nil, region_ids: []

  def start_link(opts \\ []) do
    opts = Keyword.put_new_lazy(opts, :regions, &all_enabled_regions/0)
    GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  @doc """
  Get all region ids that where started with this manager
  """
  def region_ids(pid), do: GenServer.call(pid, :region_ids)

  @doc """
  Returns the region being managed via it's region_id in the format
  of `{:ok, pid}`.  If no region exists it will instead return the
  tuple `{:error, :no_region}`
  """
  def get_region(pid, id) do
    GenServer.call(pid, {:get_region, id})
  end

  # GenServer Callbacks

  def init(opts) do
    region_opts = Keyword.take(opts, [:ip_address, :tcp_port])
    {:ok, supervisor} = start_region_supervisor()

    region_ids =
      for region_data <- opts[:regions] do
        DynamicSupervisor.start_child(
          supervisor,
          region_spec(region_data, region_opts)
        )

        region_data.region_id
      end

    {:ok, %__MODULE__{region_supervisor: supervisor, region_ids: region_ids}}
  end

  def handle_call(:region_ids, _, state) do
    {:reply, state.region_ids, state}
  end

  def handle_call({:get_region, id}, _, state) do
    case Registry.lookup(EOD.Region.Registry, {self(), id}) do
      [{pid, _}] ->
        {:reply, {:ok, pid}, state}

      [] ->
        {:reply, {:error, :no_region}, state}
    end
  end

  # Private Functions

  defp all_enabled_regions() do
    EOD.Repo.RegionData.enabled() |> EOD.Repo.all()
  end

  def region_spec(data, opts) do
    %{id: Region, start: {Region, :start_link, [data, [name: tuple_name(data)] ++ opts]}}
  end

  defp start_region_supervisor() do
    DynamicSupervisor.start_link(strategy: :one_for_one)
  end

  defp tuple_name(%{region_id: id}) do
    {:via, Registry, {EOD.Region.Registry, {self(), id}}}
  end
end
