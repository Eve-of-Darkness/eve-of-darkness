defmodule EOD.Packet.Client.PingRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.PingRequest

  test "it has a timestamp" do
    req = %PingRequest{}
    assert req.timestamp == 0
  end

  test "it can create a binary" do
    {:ok, bin} =
      %PingRequest{timestamp: 90210}
      |> PingRequest.to_binary

    assert bin == <<0, 0, 0, 0, 0, 1, 96, 98, 0, 0, 0, 0>>
  end
end
