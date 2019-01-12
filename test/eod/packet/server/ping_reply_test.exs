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
      %PingReply{timestamp: 90210, sequence: 1982}
      |> PingReply.to_binary()

    assert bin == <<90210::32, 0::32, 1982::16, 0::48>>
  end

  test "it can be built from a binary" do
    {:ok, reply} =
      <<90210::32, 0::32, 1982::16, 0::48>>
      |> PingReply.from_binary()

    assert reply.timestamp == 90210
    assert reply.sequence == 1982
  end
end
