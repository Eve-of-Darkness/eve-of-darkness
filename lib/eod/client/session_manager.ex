defmodule EOD.Client.SessionManager do
  @moduledoc """
  Clients from the game each get assigned a 2 byte integer upon successful login.
  The purpose of this module is to keep track of those session ids and hand out
  available ids as they are requested from the client.
  """
  use GenServer
  alias EOD.Client
  alias EOD.Repo.Account

  @empty :queue.new()

  defstruct session_pool: @empty,
            amount_free: 0,
            used: %{},
            accounts: MapSet.new(),
            account_lookup: %{},
            monitors: MapSet.new()

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
  Returns all accounts registered with the SessionManager as a MapSet of
  account names
  """
  def accounts_registered(pid), do: GenServer.call(pid, :accounts_registered)

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

  @doc """
  Similiar to the `register/1` function; this is intended to be called inside of
  the client process that wants to register an account to itself for the
  SessionManager.  It can return either:
    * `{:ok, :register}` = success
    * `{:error, :account_already_registered}` = account already registered to
      another process
    * `{:error, :registered_as_different_account}` = process already has a
      different account registered to it
  """
  def register_account(pid, %Account{username: username}) do
    Registry.keys(Client.Registry, self())
    |> Enum.find(&match?({:account, ^pid, _}, &1))
    |> case do
      nil ->
        with {:ok, _} <- Registry.register(Client.Registry, {:account, pid, username}, username) do
          GenServer.call(pid, {:register_account, self(), username})
        else
          {:error, {:already_registered, _}} -> {:error, :account_already_registered}
        end

      {:account, ^pid, ^username} ->
        {:ok, :registered}

      {:account, ^pid, _} ->
        {:error, :registered_as_different_account}
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

  def handle_call({:register_account, pid, acct}, _, state) do
    cond do
      state.account_lookup[pid] == acct ->
        {:reply, {:ok, :registered}, state}

      MapSet.member?(state.accounts, acct) ->
        {:reply, {:error, :account_already_registered}, state}

      state.account_lookup[pid] ->
        {:reply, {:error, :registered_as_different_account}, state}

      true ->
        state = possiby_monitor_process(state, pid)

        {:reply, {:ok, :registered},
         %{
           state
           | accounts: MapSet.put(state.accounts, acct),
             account_lookup: Map.put(state.account_lookup, pid, acct)
         }}
    end
  end

  def handle_call(:accounts_registered, _, state) do
    {:reply, state.accounts, state}
  end

  def handle_call(:amount_free, _, state) do
    {:reply, state.amount_free, state}
  end

  def handle_call({:checkout, pid}, _, state) do
    case :queue.out(state.session_pool) do
      {:empty, _} ->
        {:reply, {:error, :no_session}, state}

      {{:value, id}, session_pool} ->
        state = possiby_monitor_process(state, pid)
        amount = state.amount_free - 1

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
    new_state =
      state
      |> release_monitor(pid)
      |> possibly_free_session(pid)
      |> possibly_release_account(pid)

    {:noreply, new_state}
  end

  defp possiby_monitor_process(%{monitors: monitors} = state, pid) do
    if MapSet.member?(monitors, pid) do
      state
    else
      Process.monitor(pid)
      %{state | monitors: MapSet.put(monitors, pid)}
    end
  end

  defp release_monitor(%{monitors: monitors} = state, pid) do
    %{state | monitors: MapSet.delete(monitors, pid)}
  end

  defp possibly_free_session(state, pid) do
    case state.used[pid] do
      nil ->
        state

      id ->
        pool = :queue.in(id, state.session_pool)
        amount = state.amount_free + 1
        used = Map.delete(state.used, pid)
        %{state | session_pool: pool, amount_free: amount, used: used}
    end
  end

  defp possibly_release_account(state, pid) do
    case state.account_lookup[pid] do
      nil ->
        state

      acct ->
        lookup = Map.delete(state.account_lookup, pid)
        accts = MapSet.delete(state.accounts, acct)
        %{state | account_lookup: lookup, accounts: accts}
    end
  end
end
