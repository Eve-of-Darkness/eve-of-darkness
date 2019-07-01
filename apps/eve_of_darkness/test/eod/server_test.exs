defmodule EOD.ServerTest do
  use ExUnit.Case, async: true
  alias EOD.Server
  @registry EOD.Server.Registry

  setup _ do
    settings = %Server.Settings{server_name: "roflcopters"}

    {:ok, server} =
      start_supervised({Server, [conn_manager: :disabled, settings: settings, name: :none]})

    {:ok, server: server}
  end

  test "region_manager/1", %{server: server} do
    assert Server.region_manager(server) == {:via, Registry, {@registry, {server, :region_mgr}}}
  end

  test "client_manager/1", %{server: server} do
    name = Server.client_manager(server)
    assert name == {:via, Registry, {@registry, {server, :client_mgr}}}
  end

  test "settings/1", context do
    assert settings = %Server.Settings{} = Server.settings(context.server)
    assert settings.server_name == "roflcopters"
  end
end
