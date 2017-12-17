defmodule EOD.Client.ConnectivityPacketHandlerTest do
  use EOD.PacketHandlerCase, async: true
  alias EOD.Client.ConnectivityPacketHandler
  alias EOD.Packet.Client.{
    AcknowledgeSession,
    ClosingConnection,
    PingRequest
  }

  alias EOD.Packet.Server.PingReply

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
end
