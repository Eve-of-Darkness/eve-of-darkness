defmodule EOD.Packet.Client.AcknowledgeSessionTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.AcknowledgeSession, as: AckSession

  test "it works as a struct" do
    ack = %AckSession{}
    assert ack.session_id == 0
  end

  test "it can create a binary" do
    {:ok, bin} =
      %AckSession{session_id: 50_000}
      |> AckSession.to_binary

    assert bin == <<0xC3, 0x50, 0, 0>>
  end

  test "it can be created from a binary" do
    {:ok, ack} = <<0xC3, 0x51, 0, 0>> |> AckSession.from_binary
    assert ack == %AckSession{session_id: 50_001}
  end
end
