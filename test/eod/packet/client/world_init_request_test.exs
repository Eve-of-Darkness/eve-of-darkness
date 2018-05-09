defmodule EOD.Packet.Client.WorldInitRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.WorldInitRequest

  test "it works as a struct" do
    req = %WorldInitRequest{}
    assert req == %{__struct__: WorldInitRequest}
  end

  test "it can create a binary" do
    {:ok, bin} = %WorldInitRequest{} |> WorldInitRequest.to_binary()
    assert bin == <<0>>
  end

  test "it can be created from a binary" do
    {:ok, req} = <<0>> |> WorldInitRequest.from_binary()
    assert %WorldInitRequest{} == req
  end
end
