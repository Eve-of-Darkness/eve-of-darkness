defmodule EOD.ClientTest do
  use EOD.RepoCase, async: true

  alias EOD.{Client, Socket, TestSocket, Repo}
  alias Repo.Account

  setup _ do
    {:ok, socket} = TestSocket.start_link
    {:ok, client} = Client.start_link(%Client{tcp_socket: socket})
    Client.share_test_transaction(client)
    {:ok,
      client: client,
      socket: TestSocket.set_role(socket, :client)}
  end

  describe "Login after handshake" do
    setup context do
      handshake_request = %{
        id: :handshake_request,
        major: 1,  minor: 1,
        patch: 24, type: 6
      }

      :ok = Socket.send(context.socket, handshake_request)

      assert {:ok, %{id: :handshake_response, major: 1, minor: 1, patch: 24, type: 6}} ==
        Socket.recv(context.socket)

      :ok
    end

    test "login process happy path where account is created", context do
      login_request = %{
        id: :login_request,
        username: "test", password: "roflcopters"
      }
      refute Account.find_by_username("test") |> Repo.one
      :ok = Socket.send(context.socket, login_request)

      assert {:ok, %{id: :login_granted, major: 1, minor: 1, patch: 24, username: "test"}} ==
        Socket.recv(context.socket)

      assert Account.find_by_username("test") |> Repo.one
    end

    test "login process where account exists and password is correct", context do
      insert(:account, username: "timmy")
      login_request = %{
        id: :login_request,
        username: "timmy", password: "test-password"
      }

      :ok = Socket.send(context.socket, login_request)

      assert {:ok, %{id: :login_granted, major: 1, minor: 1, patch: 24, username: "timmy"}} ==
        Socket.recv(context.socket)
    end

    test "login process where account exists and password is wrong", context do
      insert(:account, username: "timmy")
      login_request = %{
        id: :login_request,
        username: "timmy", password: "bad-password"
      }

      :ok = Socket.send(context.socket, login_request)

      assert {:ok, %{id: :login_denied, reason: :wrong_password, major: 1, minor: 1, patch: 24}} ==
        Socket.recv(context.socket)

      assert {:error, :closed} = Socket.recv(context.socket)
    end

    test "login process where no account, but data is bad", context do
      login_request = %{id: :login_request, username: "s", password: "ad"}
      :ok = Socket.send(context.socket, login_request)
      assert {:ok, %{id: :login_denied, reason: :account_invalid, major: 1, minor: 1, patch: 24}} ==
        Socket.recv(context.socket)

      assert {:error, :closed} = Socket.recv(context.socket)
    end
  end
end
