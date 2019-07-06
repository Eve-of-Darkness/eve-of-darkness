defmodule EOD.Client.LoadPlayerPacketHandlerTest do
  use EOD.PacketHandlerCase, async: true
  alias EOD.Client.LoadPlayerPacketHandler

  alias EOD.Packet.Server.{
    GameOpenReply,
    CharacterStatusUpdate,
    SelfLocationInformation,
    CharacterPointsUpdate,
    Encumberance,
    PlayerSpeed
  }

  alias EOD.Packet.Client.{GameOpenRequest, WorldInitRequest}
  alias EOD.Player

  setup context do
    selected_char = context[:selected_char] || insert(:character)

    {:ok,
     handler: LoadPlayerPacketHandler,
     client: %{context.client | selected_character: selected_char}}
  end

  describe "game_open_request" do
    test "the communication flow", context do
      handle_packet(context, %GameOpenRequest{})
      assert %GameOpenReply{} = received_packet(context)

      assert_receive {:"$gen_cast", {:send_message, msg}}
      assert msg.__struct__ == CharacterStatusUpdate

      assert_receive {:"$gen_cast", {:send_message, msg}}
      assert msg.__struct__ == CharacterPointsUpdate
    end
  end

  describe "world_init_request" do
    setup %{client: client} do
      {:ok, player} = Player.start_link(client.selected_character)
      {:ok, client: put_in(client.player, player)}
    end

    @tag :pending
    test "a self location packet is sent", context do
      handle_packet(context, %WorldInitRequest{})

      assert_receive {:"$gen_cast", {:send_message, msg}}
      assert msg.__struct__ == SelfLocationInformation

      assert_receive {:"$gen_cast", {:send_message, msg}}
      assert msg.__struct__ == Encumberance

      assert_receive {:"$gen_cast", {:send_message, msg}}
      assert msg.__struct__ == PlayerSpeed

      assert_receive {:"$gen_cast", {:send_message, msg}}
      assert msg.__struct__ == PlayerSpeed

      assert_receive {:"$gen_cast", {:send_message, msg}}
      assert msg.__struct__ == CharacterStatusUpdate
    end
  end
end
