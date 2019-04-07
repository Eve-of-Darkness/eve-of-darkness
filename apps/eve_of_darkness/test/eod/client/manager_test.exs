defmodule EOD.Client.ManagerTest do
  use ExUnit.Case, async: true
  alias EOD.Client.Manager

  setup _ do
    {:ok, manager} = Manager.start_link()
    {:ok, socket} = EOD.TestSocket.start_link()
    {:ok, manager: manager, socket: socket}
  end

  test "can return how many clients are actively running", context do
    assert 0 == Manager.client_count(context.manager)
  end

  test "can start a client with just a socket", context do
    assert :ok == Manager.start_client(context.manager, context.socket)
    assert 1 == Manager.client_count(context.manager)
  end
end
