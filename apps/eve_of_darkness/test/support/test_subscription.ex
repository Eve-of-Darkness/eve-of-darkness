defmodule EOD.TestSubscription do
  use GenServer
  alias EOD.Socket.Inspector

  @moduledoc """
  This is to help test functionality around the game sockets with
  regards to their inspection functionality
  """

  @buckets [:notify, :shutdown, :unsub, :sub]
  @default_state @buckets
                 |> Enum.map(&[{:"#{&1}_logs", []}, {:"#{&1}_waiting", []}])
                 |> List.flatten()
                 |> Enum.into(%{id: nil})

  defstruct pid: nil

  def start_link do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    {:ok, %__MODULE__{pid: pid}}
  end

  def init(_), do: {:ok, %{@default_state | id: make_ref()}}

  def get_logs(%{pid: pid}, amount \\ 1, timeout \\ 1_000),
    do: GenServer.call(pid, {:get, :notify, amount}, timeout)

  def get_shutdowns(%{pid: pid}, amount \\ 1, timeout \\ 1_000),
    do: GenServer.call(pid, {:get, :shutdown, amount}, timeout)

  def get_subscribes(%{pid: pid}, amount \\ 1, timeout \\ 1_000),
    do: GenServer.call(pid, {:get, :sub, amount}, timeout)

  def get_unsubscribes(%{pid: pid}, amount \\ 1, timeout \\ 1_000),
    do: GenServer.call(pid, {:get, :unsub, amount}, timeout)

  @doc """
  Because an Inspector subscribe is async we can run into troubles with
  testing messages that come through to a subscription because there is
  a chance that the subscription hasn't truely been attached to the inspector
  yet.  With that in mind, this function will block until the provided
  subscription is confirmed to subscribe with the inspector.  An optional
  timeout of one second can be given.
  """
  def wait_for_subscribtion(subscription, inspector, timeout \\ 1_000) do
    fn -> subscribed_yet?(subscription, inspector, true) end
    |> Task.async()
    |> Task.await(timeout)
  end

  @doc """
  Same as wait_for_subscribtion/3 but in the reverse
  """
  def wait_for_unsubscribe(subscription, inspector, timeout \\ 1_000) do
    fn -> subscribed_yet?(subscription, inspector, false) end
    |> Task.async()
    |> Task.await(timeout)
  end

  for bucket <- @buckets do
    logb = :"#{bucket}_logs"
    logw = :"#{bucket}_waiting"

    def handle_call(
          {:get, unquote(bucket), amount},
          client,
          %{unquote(logb) => logs, unquote(logw) => waiting} = state
        )
        when amount > length(logs) do
      {:noreply, %{state | unquote(logw) => [{client, amount} | waiting]}}
    end

    def handle_call({:get, unquote(bucket), amount}, _, %{unquote(logb) => logs} = state) do
      {taken, remaining} = logs |> Enum.reverse() |> Enum.split(amount)
      {:reply, taken, %{state | unquote(logb) => remaining}}
    end

    def handle_call(
          {:put, unquote(bucket), val},
          _,
          %{unquote(logb) => logs, unquote(logw) => []} = state
        ) do
      {:reply, :ok, %{state | unquote(logb) => [val | logs]}}
    end

    def handle_call(
          {:put, unquote(bucket), val},
          _,
          %{unquote(logb) => logs, unquote(logw) => [{_, amount}]} = state
        )
        when amount > length(logs) + 1 do
      {:reply, :ok, %{state | unquote(logb) => [val | logs]}}
    end

    def handle_call(
          {:put, unquote(bucket), val},
          _,
          %{unquote(logb) => logs, unquote(logw) => [{client, amount}]} = state
        ) do
      {taken, remaining} = [val | logs] |> Enum.reverse() |> Enum.split(amount)
      GenServer.reply(client, taken)
      {:reply, :ok, %{state | unquote(logb) => remaining, unquote(logw) => []}}
    end
  end

  def handle_call(:get_id, _, %{id: id} = state), do: {:reply, id, state}

  defp subscribed_yet?(sub, inspector, result) do
    if Inspector.subscribed?(inspector, sub) == result do
      :ok
    else
      subscribed_yet?(sub, inspector, result)
    end
  end
end

defimpl EOD.Socket.Inspector.Subscription, for: EOD.TestSubscription do
  def notify(%{pid: pid}, action, id, meta, data) do
    GenServer.call(pid, {:put, :notify, %{id: id, action: action, meta: meta, data: data}})
  end

  def id(%{pid: pid}), do: GenServer.call(pid, :get_id)

  def shutting_down(%{pid: pid}, id, meta),
    do: GenServer.call(pid, {:put, :shutdown, %{id: id, meta: meta}})

  def unsubscribing(%{pid: pid}, id, meta),
    do: GenServer.call(pid, {:put, :unsub, %{id: id, meta: meta}})

  def subscribing(%{pid: pid}, id, meta),
    do: GenServer.call(pid, {:put, :sub, %{id: id, meta: meta}})
end
