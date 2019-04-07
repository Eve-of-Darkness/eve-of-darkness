defmodule EOD.Packet.Server.PingReplyTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.PingReply

  test "it has a timestamp and sequence" do
    req = %PingReply{}
    assert req.timestamp == 0
    assert req.sequence == 0
  end

  test "it can build a binary" do
    {:ok, bin} =
      %PingReply{timestamp: 90_210, sequence: 1_982}
      |> PingReply.to_binary()

    assert bin == <<90_210::32, 0::32, 1_982::16, 0::48>>
  end

  test "it can be built from a binary" do
    {:ok, reply} =
      <<90_210::32, 0::32, 1_982::16, 0::48>>
      |> PingReply.from_binary()

    assert reply.timestamp == 90_210
    assert reply.sequence == 1_982
  end
end
