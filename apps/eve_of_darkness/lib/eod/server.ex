defmodule EOD.Server do
  @moduledoc """
  Responsible for orchestrating the back & forth talk
  between clients and delegating to the different
  logic centers of the game
  """
  use GenServer
  alias EOD.Server.{ConnManager, Settings}
  alias EOD.{Client, Socket, Region}
  require Logger

  defstruct conn_manager: nil,
            client_manager: nil,
            region_manager: nil,
            settings: nil,
            ref: nil

  @doc """
  Starts a EOD Server.  There are some options; some of which are meant more
  so for testing then anything else.

  Options:
    * `ref`
      By default the server creates an internal reference which it
      uses to match on messages sent directly to it by trusted processes.
      If you want to be able to send messages directly to the server
      process for these conditions you'll need to specify this.

    * `conn_manager`
      If this is left out the server will boot up it's default connection
      manager; however, if this option is provided it will be used and
      the default manager will not be booted.

    * `settings`
      This should be an `EOD.Server.Settings` struct.  If left absent
      it will default to `EOD.Server.Settings.new/0`

    * `name`
      This is the alias pid to which the server is alias; if provided;
      otherwise it defaults to `EOD.Server`.  You can also specify a
      special option of `:none` which opts out of registering the pid
      under a name
  """
  def start_link(opts \\ []) do
    ref = opts[:ref] || make_ref()
    conn_manager = opts[:conn_manager]

    settings = Keyword.get_lazy(opts, :settings, fn -> Settings.new() end)

    GenServer.start_link(
      __MODULE__,
      %__MODULE__{ref: ref, settings: settings, conn_manager: conn_manager},
      genserver_opts(opts)
    )
  end

  @doc """
  Returns the `EOD.Region.Manager` process being managed by the server
  """
  def region_manager(pid), do: GenServer.call(pid, :get_region_manager)

  @doc """
  Returns the `EOD.Client.Manager` process bieng managed by the server
  """
  def client_manager(pid), do: GenServer.call(pid, :get_client_manager)

  @doc """
  Returns the `EOD.Server.Settings` struct for a given server process
  """
  def settings(pid), do: GenServer.call(pid, :get_settings)

  # GenServer Callbacks

  def init(%__MODULE__{} = state) do
    with {:ok, client_manager} <- Client.Manager.start_link(),
         {:ok, region_manager} <- boot_region_manager(state) do
      send(self(), {:boot_conn_manager, state.ref})
      {:ok, %{state | client_manager: client_manager, region_manager: region_manager}}
    end
  end

  def handle_call(:get_region_manager, _, state) do
    {:reply, state.region_manager, state}
  end

  def handle_call(:get_client_manager, _, state) do
    {:reply, state.client_manager, state}
  end

  def handle_call(:get_settings, _, state) do
    {:reply, state.settings, state}
  end

  def handle_info({:boot_conn_manager, ref}, %{ref: ref, conn_manager: nil} = state) do
    {:ok, conn_manager} = ConnManager.start_link(conn_manager_opts(state))
    {:noreply, %{state | conn_manager: conn_manager}}
  end

  def handle_info({:boot_conn_manager, ref}, %{ref: ref} = state) do
    {:noreply, state}
  end

  # Private Functions

  defp genserver_opts(opts) do
    case opts[:name] do
      nil ->
        [name: EOD.Server]

      :none ->
        []

      any ->
        [name: any]
    end
  end

  defp conn_manager_opts(%{settings: settings, client_manager: manager}) do
    [
      port: settings.tcp_port,
      callback: {:call, {Client.Manager, :start_client, [manager, [server: self()]]}},
      wrap: {Socket.TCP.GameSocket, :new, []}
    ]
  end

  defp boot_region_manager(%{settings: settings}) do
    opts =
      []
      |> Keyword.put(:ip_address, settings.tcp_address)
      |> Keyword.put(:tcp_port, settings.tcp_port)
      |> Keyword.put(:regions, settings.regions)

    Region.Manager.start_link(opts)
  end
end
