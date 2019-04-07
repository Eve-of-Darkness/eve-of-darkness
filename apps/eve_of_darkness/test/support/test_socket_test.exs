defmodule EOD.TestSocketTest do
  use ExUnit.Case, async: true
  alias EOD.{TestSocket, Socket}

  setup _ do
    {:ok, socket} = TestSocket.start_link()

    {:ok,
     server: TestSocket.set_role(socket, :server), client: TestSocket.set_role(socket, :client)}
  end

  test "send from client to server", conn do
    assert :ok = Socket.send(conn.client, "test")
    assert {:ok, "test"} = Socket.recv(conn.server)
  end

  test "send from server to client", conn do
    assert :ok = Socket.send(conn.server, "rofl")
    assert {:ok, "rofl"} = Socket.recv(conn.client)
  end

  test "client recieve before send blocks", conn do
    task = Task.async(fn -> Socket.recv(conn.client) end)
    assert :ok = Socket.send(conn.server, "test")
    assert {:ok, "test"} = Task.await(task)
  end

  test "server recieve before send blocks", conn do
    task = Task.async(fn -> Socket.recv(conn.server) end)
    assert :ok = Socket.send(conn.client, "test")
    assert {:ok, "test"} = Task.await(task)
  end

  test "everyone waiting gets {:error, :closed} on close", conn do
    client = Task.async(fn -> Socket.recv(conn.client) end)
    server = Task.async(fn -> Socket.recv(conn.server) end)
    assert :ok = Socket.close(conn.server)
    assert {:error, :closed} = Task.await(client)
    assert {:error, :closed} = Task.await(server)
  end

  test "a closed socket sends {:error, :closed}", conn do
    assert :ok = Socket.close(conn.client)
    assert {:error, :closed} = Socket.recv(conn.server)
  end

  test "queues up messages", conn do
    Socket.send(conn.server, "server 1")
    Socket.send(conn.server, "server 2")
    Socket.send(conn.client, "client 1")
    Socket.send(conn.client, "client 2")

    assert {:ok, "server 1"} = Socket.recv(conn.client)
    assert {:ok, "server 2"} = Socket.recv(conn.client)
    assert {:ok, "client 1"} = Socket.recv(conn.server)
    assert {:ok, "client 2"} = Socket.recv(conn.server)
  end
end
