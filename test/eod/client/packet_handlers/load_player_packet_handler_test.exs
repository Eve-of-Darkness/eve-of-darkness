defmodule EOD.Client.LoadPlayerPacketHandlerTest do
  use EOD.PacketHandlerCase, async: true
  alias EOD.Client.LoadPlayerPacketHandler

  alias EOD.Packet.Server.{GameOpenReply, CharacterStatusUpdate, CharacterPointsUpdate}
  alias EOD.Packet.Client.GameOpenRequest

  setup context do
    selected_char = context[:selected_char] || build(:character)
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
end
