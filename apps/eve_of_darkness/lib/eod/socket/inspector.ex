defmodule EOD.Socket.Inspector do
  @moduledoc """
  When it comes to debugging hard to find network problems or attempting
  to add new packet functionality; it can be very difficult to figure out
  what's happening.  The goal of this module is to aid in packet traffic
  and bridge socket information to other modules which can then present
  this stream of data in a more meaningful way for development.
  """
  use GenServer
  alias __MODULE__, as: Inspector
  alias EOD.Socket.Inspector.Subscription

  defstruct pid: nil

  defmodule State do
    @moduledoc false
    defstruct metadata: %{},
              subscriptions: %{},
              id: nil
  end

  def start_link(opts \\ []) do
    metadata = Keyword.get(opts, :metadata, %{})
    id = Keyword.get_lazy(opts, :id, &make_ref/0)

    {:ok, pid} = GenServer.start_link(Inspector, %State{metadata: metadata, id: id})

    {:ok, %__MODULE__{pid: pid}}
  end

  def inspect_recv(%Inspector{pid: pid}, data) do
    GenServer.cast(pid, {:inspect, :recv, data})
  end

  def inspect_send(%Inspector{pid: pid}, data) do
    GenServer.cast(pid, {:inspect, :send, data})
  end

  def subscribe(%Inspector{pid: pid}, subscription) do
    GenServer.cast(pid, {:subscribe, subscription})
  end

  def unsubscribe(%Inspector{pid: pid}, subscription) do
    GenServer.cast(pid, {:unsubscribe, subscription})
  end

  def subscribed?(%Inspector{pid: pid}, subscription) do
    GenServer.call(pid, {:subscribed?, subscription})
  end

  def shutdown(%Inspector{pid: pid}) do
    GenServer.stop(pid)
  end

  ## GenServer Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:inspect, _, _}, %{subscriptions: []} = state) do
    {:noreply, state}
  end

  def handle_cast({:inspect, dir, data}, %{id: id, subscriptions: subs, metadata: meta} = state) do
    subs
    |> Map.values()
    |> Enum.each(&Subscription.notify(&1, dir, id, meta, data))

    {:noreply, state}
  end

  def handle_cast(
        {:subscribe, subscription},
        %{id: id, metadata: meta, subscriptions: subs} = state
      ) do
    sub_id = Subscription.id(subscription)
    Subscription.subscribing(subscription, id, meta)
    {:noreply, %{state | subscriptions: Map.put(subs, sub_id, subscription)}}
  end

  def handle_cast(
        {:unsubscribe, subscription},
        %{id: id, metadata: meta, subscriptions: subs} = state
      ) do
    sub_id = Subscription.id(subscription)
    Subscription.unsubscribing(subscription, id, meta)
    {:noreply, %{state | subscriptions: Map.delete(subs, sub_id)}}
  end

  def handle_call({:subscribed?, subscription}, _, %{subscriptions: subs} = state) do
    id = Subscription.id(subscription)
    {:reply, Map.has_key?(subs, id), state}
  end
end
