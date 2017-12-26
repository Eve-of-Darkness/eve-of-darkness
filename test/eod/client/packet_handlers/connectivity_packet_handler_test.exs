defmodule EOD.Client.ConnectivityPacketHandlerTest do
  use EOD.PacketHandlerCase, async: true
  alias EOD.Client.ConnectivityPacketHandler
  alias EOD.Packet.Client.{
    AcknowledgeSession,
    ClosingConnection,
    PingRequest,
    RegionRequest
  }

  alias EOD.Packet.Server.{PingReply, RegionReply}

  setup _ do
    {:ok, handler: ConnectivityPacketHandler}
  end

  test "ping_request", context do
    handle_packet(context, %PingRequest{timestamp: 90210})
    reply = %PingReply{} = received_packet(context)
    assert reply.timestamp == 90210
    assert reply.sequence == 1
  end

  test "acknowledge_session", context do
    client = handle_packet(context, %AcknowledgeSession{session_id: 39837})
    assert context.client == client
  end

  test "closing_connection", context do
    handle_packet(context, %ClosingConnection{})
    assert disconnected?(context)
  end

  describe "region_request" do
    setup context do
      char = context[:character] || build(:character, region: 27)
      region = build(:region_data, region_id: 27, name: "region027")

      settings = %Server.Settings{
        tcp_address: "192.168.1.111",
        tcp_port: 45_123,
        regions: [region]}

      {:ok, server} = Server.start_link(conn_manager: :disabled, settings: settings)

      {:ok,
        client: %{context.client |
          selected_character: char,
          server: server},
        server: server}
    end

    test "with a selected character it if returns a region reply", context do
      handle_packet(context, %RegionRequest{})
      reply = %RegionReply{} = received_packet(context)
      assert reply.id == 27
      assert reply.name == "region027" 
      assert reply.port_1 == "45123"
      assert reply.port_2 == "45123"
      assert reply.ip_address == "192.168.1.111"
    end
  end
end
