defmodule EOD.Packet.Client.RegionRequestTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.RegionRequest

  test "it works as a struct" do
    req = %RegionRequest{}
    assert req == %{__struct__: RegionRequest}
  end

  test "it create a binary" do
    {:ok, bin} = %RegionRequest{} |> RegionRequest.to_binary()
    assert bin == String.duplicate(<<0>>, 30)
  end

  test "it can be created from a binary" do
    {:ok, req} =
      String.duplicate(<<0>>, 30)
      |> RegionRequest.from_binary()

    assert %RegionRequest{} = req
  end
end
