defmodule EOD.ClientTest do
  use EOD.RepoCase, async: true

  alias EOD.{Client, Socket, TestSocket, Repo}
  alias Repo.Account
  alias Client.SessionManager

  alias EOD.Socket.TCP.ClientPacket
  alias EOD.Packet.Client.{LoginRequest, HandShakeRequest}
  alias EOD.Packet.Server.{LoginGranted, LoginDenied, HandshakeResponse}

  setup tags do
    {:ok, socket} = TestSocket.start_link
    {:ok, sessions} = SessionManager.start_link(id_pool: tags[:id_pool] || [1, 2, 3])
    {:ok, client} = Client.start_link(%Client{tcp_socket: socket, sessions: sessions})
    Client.share_test_transaction(client)
    {:ok,
      client: client,
      socket: TestSocket.set_role(socket, :client)}
  end

  test "send_message/2", %{client: client, socket: socket} do
    client |> Client.send_message(:rofltest)
    assert {:ok, :rofltest} == Socket.recv(socket)
  end

  describe "Login after handshake" do
    setup context do
      handshake_request = %ClientPacket{
        id: :handshake_request,
        data: %HandShakeRequest{
          major: 1,  minor: 1,
          patch: 24, type: 6, rev: 92,
          build: 1982
        }
      }

      :ok = Socket.send(context.socket, handshake_request)

      assert {:ok, %HandshakeResponse{type: 6, version: "1.124", rev: 92, build: 1982}} ==
        Socket.recv(context.socket)

      :ok
    end

    test "login process happy path where account is created", context do
      login_request = %ClientPacket{
        id: :login_request,
        data: %LoginRequest{
          username: "test", password: "roflcopters"
        }
      }

      refute Account.find_by_username("test") |> Repo.one
      :ok = Socket.send(context.socket, login_request)

      assert {:ok, %LoginGranted{username: "test", server_name: "EOD"}} ==
        Socket.recv(context.socket)

      assert Account.find_by_username("test") |> Repo.one
    end

    @tag id_pool: []
    test "login process where the server is full", context do
      login_request = %ClientPacket{
        id: :login_request,
        data: %LoginRequest{
          username: "test", password: "roflcopters"
        }
      }

      :ok = Socket.send(context.socket,  login_request)

      assert {:ok, %LoginDenied{reason: :too_many_players_logged_in, major: 1, minor: 1}} ==
        Socket.recv(context.socket)
    end

    test "login process where account exists and password is correct", context do
      insert(:account, username: "timmy")
      login_request = %ClientPacket{
        id: :login_request,
        data: %LoginRequest{
          username: "timmy", password: "test-password"
        }
      }

      :ok = Socket.send(context.socket, login_request)

      assert {:ok, %LoginGranted{username: "timmy", server_name: "EOD"}} ==
        Socket.recv(context.socket)
    end

    test "login process where account exists and password is wrong", context do
      insert(:account, username: "timmy")
      login_request = %ClientPacket{
        id: :login_request,
        data: %LoginRequest{
          username: "timmy", password: "bad-password"
        }
      }

      :ok = Socket.send(context.socket, login_request)

      assert {:ok, %LoginDenied{reason: :wrong_password, major: 1, minor: 1}} ==
        Socket.recv(context.socket)

      assert {:error, :closed} = Socket.recv(context.socket)
    end

    test "login process where no account, but data is bad", context do
      login_request = %ClientPacket{
        id: :login_request,
        data: %LoginRequest{username: "s", password: "ad"}}

      :ok = Socket.send(context.socket, login_request)
      assert {:ok, %LoginDenied{reason: :account_invalid, major: 1, minor: 1}} ==
        Socket.recv(context.socket)

      assert {:error, :closed} = Socket.recv(context.socket)
    end

    test "ping requests are answered", context do
      alias EOD.Packet.Client.PingRequest
      alias EOD.Packet.Server.PingReply

      ping_request = %ClientPacket{
        id: :ping_request,
        sequence: 3,
        data: %PingRequest{timestamp: 90210}
      }

      :ok = Socket.send(context.socket, ping_request)

      assert {:ok, %PingReply{timestamp: 90210, sequence: 4}} ==
        Socket.recv(context.socket)
    end
  end
end
