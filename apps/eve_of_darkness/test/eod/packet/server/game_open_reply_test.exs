defmodule EOD.Packet.Server.GameOpenReplyTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.GameOpenReply

  test "it works as a struct" do
    reply = %GameOpenReply{}
    assert reply.__struct__ == GameOpenReply
  end

  test "it can create a binary" do
    {:ok, bin} = %GameOpenReply{} |> GameOpenReply.to_binary()
    assert bin == <<0>>
  end

  test "it can be created from a binary" do
    {:ok, reply} = <<0>> |> GameOpenReply.from_binary()
    assert reply.__struct__ == GameOpenReply
  end
end
