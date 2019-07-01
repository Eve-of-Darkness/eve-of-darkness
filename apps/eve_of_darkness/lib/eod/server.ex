defmodule EOD.Server do
  @moduledoc """
  Responsible for starting up and supervisoring all the important workers and
  supervisors needed to orchestrate a running server.  All of the major parts
  are registered and "namespace" to the started supervisor by it's name or pid
  """
  use Supervisor
  alias EOD.{Client, Socket, Region}
  alias EOD.Server.{ConnManager, Settings}

  @registry EOD.Server.Registry

  @doc """
  Starts a EOD Server.  There are some options; some of which are meant more
  so for testing then anything else.

  Options:
    * `conn_manager`
      If this is left out the server will boot up it's default connection
      manager; however, if this option is set to `:disabled` a connection
      manager will not be booted

    * `settings`
      This should be an `EOD.Server.Settings` struct.  If left absent
      it will default to `EOD.Server.Settings.new/0`

    * `name`
      This is the alias to which the server is registered if provided;
      otherwise it defaults to `EOD.Server`.  You can also specify a
      special option of `:none` which opts out of registering the pid
      under a name.
  """
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, supervisor_opts(opts))
  end

  @doc """
  Returns the name of the `EOD.Client.Manager` process being supervised by the server
  """
  def client_manager(server), do: {:via, Registry, {@registry, {server, :client_mgr}}}

  @doc """
  Returns the name of the `EOD.Region.Manager` process being supervised by the server
  """
  def region_manager(server), do: {:via, Registry, {@registry, {server, :region_mgr}}}

  @doc """
  Returns the `EOD.Server.Settings` struct that was used to start the server
  """
  def settings(server), do: server |> settings_agent() |> Agent.get(& &1)

  ## Supervisor Callback

  @impl true
  def init(opts) do
    settings = Keyword.get_lazy(opts, :settings, fn -> Settings.new() end)
    server = server_name(opts)

    Supervisor.init(
      [
        settings_spec(server, settings),
        {Client.Manager, name: client_manager(server)},
        {Region.Manager, region_manager_opts(server, settings)}
      ] ++ potential_conn_manager(opts, server, settings),
      strategy: :rest_for_one
    )
  end

  ## Private Functions

  defp settings_spec(server, settings) do
    %{
      id: Agent,
      start: {Agent, :start_link, [fn -> settings end, [name: settings_agent(server)]]}
    }
  end

  defp settings_agent(server), do: {:via, Registry, {@registry, {server, :settings}}}

  defp server_name(opts) do
    case opts[:name] do
      nil -> EOD.Server
      :none -> self()
      any -> any
    end
  end

  defp supervisor_opts(opts) do
    case opts[:name] do
      nil ->
        [name: EOD.Server]

      :none ->
        []

      any ->
        [name: any]
    end
  end

  defp potential_conn_manager(opts, server, settings) do
    if opts[:conn_manager] == :disabled do
      []
    else
      {ConnManager, conn_manager_opts(server, settings)}
    end
  end

  defp conn_manager_opts(server, settings) do
    [
      port: settings.tcp_port,
      callback:
        {:call, {Client.Manager, :start_client, [client_manager(server), [server: server]]}},
      wrap: {Socket.TCP.GameSocket, :new, []}
    ]
  end

  defp region_manager_opts(server, settings) do
    []
    |> Keyword.put(:ip_address, settings.tcp_address)
    |> Keyword.put(:tcp_port, settings.tcp_port)
    |> Keyword.put(:regions, settings.regions)
    |> Keyword.put(:name, region_manager(server))
  end
end
