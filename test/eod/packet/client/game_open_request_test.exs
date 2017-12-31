defmodule EOD.Packet.Client.GameOpenRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.GameOpenRequest

  test "it works as a struct" do
    req = %GameOpenRequest{}
    assert req.udp_verfied == 0
  end

  test "it can create a binary" do
    {:ok, bin} =
      %GameOpenRequest{udp_verfied: 1}
      |> GameOpenRequest.to_binary

    assert bin == <<1>>
  end

  test "it can be created from a binary" do
    {:ok, req} = <<0>> |> GameOpenRequest.from_binary
    assert req.udp_verfied == 0
    assert req.__struct__ == GameOpenRequest
  end
end
