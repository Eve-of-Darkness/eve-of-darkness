defmodule EOD.Client.ManagerTest do
  use ExUnit.Case, async: true
  alias EOD.Client.Manager

  setup context do
    opts = context[:opts] || []
    {:ok, manager} = start_supervised({Manager, opts})
    {:ok, socket} = EOD.TestSocket.start_link()
    {:ok, manager: manager, socket: socket}
  end

  test "can return how many clients are actively running", context do
    assert 0 == Manager.client_count(context.manager)
  end

  test "can start a client with just a socket", context do
    assert :ok == Manager.start_client(context.socket, context.manager)
    assert 1 == Manager.client_count(context.manager)
  end

  test "if a client dies the count is still correct", context do
    assert :ok == Manager.start_client(context.socket, context.manager)
    assert 1 == Manager.client_count(context.manager)
    client = get_first_found_client_pid(context)
    GenServer.stop(client)
    assert 0 == Manager.client_count(context.manager)
  end

  @name {:via, Registry, {EOD.Server.Registry, :rofl_client}}
  @tag opts: [name: @name]
  test "can be given a via tuple name for startup", context do
    assert :ok == Manager.start_client(context.socket, @name)
  end

  defp get_first_found_client_pid(%{manager: manager}) do
    manager
    |> :sys.get_state()
    |> Map.get(:clients)
    |> Supervisor.which_children()
    |> hd()
    |> elem(1)
  end
end
