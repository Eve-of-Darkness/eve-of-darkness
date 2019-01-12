defmodule EOD.Client.SessionManager do
  @moduledoc """
  Clients from the game each get assigned a 2 byte integer upon successful login.
  The purpose of this module is to keep track of those session ids and hand out
  available ids as they are requested from the client.
  """
  use GenServer
  alias EOD.Client

  @empty :queue.new()

  defstruct session_pool: @empty,
            amount_free: 0,
            used: %{}

  @doc """
  Returns a session manager which can be used to register clients.  It accepts
  a list or range of integers to use for session ids. Please note that these
  numbers are limited by two bytes, so the max permitted is 65,535.

  options
    * :id_pool - list or range of ints to use as sessions
  """
  def start_link(opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      opts |> Keyword.put_new(:id_pool, 1..65_535)
    )
  end

  @doc """
  A quick check to see if there are any sessions available. Note that because
  of process timing; just because this returns true does **not** mean there
  will be a session when you call `register/1`.
  """
  def sessions_availale?(pid), do: amount_free(pid) > 0

  @doc """
  Returns the number of sessions left that can be registered
  """
  def amount_free(pid), do: GenServer.call(pid, :amount_free)

  @doc """
  Intended to be called from inside the `EOD.Client`.  This registers the
  process with an available session id and returns it in the form of `{:ok, id}`.
  Calling this twice in the same process has no effect but to return the same
  id with which it's already registered.  If there are no available session ids
  it returns `{:error, :no_session}`.
  """
  def register(pid) do
    Registry.keys(Client.Registry, self())
    |> Enum.find(&match?({:session_id, ^pid, _}, &1))
    |> case do
      nil ->
        with {:ok, id} <- GenServer.call(pid, {:checkout, self()}) do
          Registry.register(Client.Registry, {:session_id, pid, id}, id)
          {:ok, id}
        end

      {:session_id, ^pid, id} ->
        {:ok, id}
    end
  end

  # GenServer Callbacks

  def init(opts) do
    session_pool = opts[:id_pool] |> Enum.to_list() |> :queue.from_list()

    {:ok,
     %__MODULE__{
       session_pool: session_pool,
       amount_free: session_pool |> :queue.len()
     }}
  end

  def handle_call(:amount_free, _, state) do
    {:reply, state.amount_free, state}
  end

  def handle_call({:checkout, pid}, _, state) do
    case :queue.out(state.session_pool) do
      {:empty, _} ->
        {:reply, {:error, :no_session}, state}

      {{:value, id}, session_pool} ->
        amount = state.amount_free - 1
        Process.monitor(pid)

        {:reply, {:ok, id},
         %{
           state
           | session_pool: session_pool,
             amount_free: amount,
             used: Map.put(state.used, pid, id)
         }}
    end
  end

  def handle_call(:get_ref, _, state), do: {:reply, state.ref, state}

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    case state.used[pid] do
      nil ->
        {:noreply, state}

      id ->
        pool = :queue.in(id, state.session_pool)
        amount = state.amount_free + 1
        used = Map.delete(state.used, pid)
        {:noreply, %{state | session_pool: pool, amount_free: amount, used: used}}
    end
  end
end
