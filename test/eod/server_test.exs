defmodule EOD.ServerTest do
  use ExUnit.Case, async: true
  alias EOD.Server

  setup _ do
    settings = %Server.Settings{server_name: "roflcopters"}
    {:ok, server} = Server.start_link(conn_manager: :disabled, settings: settings)
    {:ok, server: server}
  end

  test "region_manager/1", context do
    assert Server.region_manager(context.server) |> is_pid
  end

  test "client_manager/1", context do
    assert Server.client_manager(context.server) |> is_pid
  end

  test "settings/1", context do
    assert settings = %Server.Settings{} = Server.settings(context.server)
    assert settings.server_name == "roflcopters"
  end
end
