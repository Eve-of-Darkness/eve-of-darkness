defmodule EOD.Packet.Server.RegionReplyTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.RegionReply

  test "it works as a struct" do
    reply = %RegionReply{}
    assert reply.id == 0
    assert reply.name == ""
    assert reply.port_1 == ""
    assert reply.port_2 == ""
    assert reply.ip_address == ""
  end

  test "it can create a binary" do
    region = %RegionReply{
      id: 18,
      name: "region018",
      port_1: "10300",
      port_2: "10300",
      ip_address: "192.168.1.130"
    }

    {:ok, bin} = region |> RegionReply.to_binary()

    assert bin ==
             <<0, 18>> <> pad("region018", 20) <> "10300" <> "10300" <> pad("192.168.1.130", 20)
  end

  defp pad(str, amount), do: String.pad_trailing(str, amount, <<0>>)
end
