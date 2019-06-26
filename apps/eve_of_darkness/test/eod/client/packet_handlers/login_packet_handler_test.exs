defmodule EOD.Client.LoginPacketHandlerTest do
  use EOD.PacketHandlerCase, async: true

  alias EOD.Client.{
    LoginPacketHandler,
    SessionManager
  }

  alias EOD.Packet.Client.LoginRequest

  alias EOD.Packet.Server.{
    LoginGranted,
    LoginDenied
  }

  setup context do
    acct =
      insert(:account,
        username: "benfalk",
        password: Pbkdf2.hash_pwd_salt("roflcopter")
      )

    {:ok, sm} = SessionManager.start_link()

    {:ok,
     handler: LoginPacketHandler,
     account: acct,
     session_manager: sm,
     client: %{
       context.client
       | account: nil,
         state: :handshake,
         sessions: sm,
         version: %{major: 1, minor: 1, patch: 2, rev: 4, build: 3}
     }}
  end

  describe "login_request" do
    test "with a good login request", context do
      packet = %LoginRequest{username: "benfalk", password: "roflcopter"}
      handle_packet(context, packet)
      assert %LoginGranted{username: "benfalk"} = received_packet(context)
    end

    test "with a bad password", context do
      packet = %LoginRequest{username: "benfalk", password: "bad-password"}
      handle_packet(context, packet)
      assert %LoginDenied{reason: :wrong_password} = received_packet(context)
    end

    test "with account already signed in", context do
      # Simulate another client with this account registered
      Task.async(fn ->
        SessionManager.register_account(context.session_manager, context.account)
        :timer.sleep(1000)
      end)

      packet = %LoginRequest{username: "benfalk", password: "roflcopter"}
      handle_packet(context, packet)
      assert %LoginDenied{reason: :account_already_logged_in} = received_packet(context)
    end
  end
end
