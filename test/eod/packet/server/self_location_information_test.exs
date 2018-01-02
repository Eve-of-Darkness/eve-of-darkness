defmodule EOD.Packet.Server.SelfLocationInformationTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.SelfLocationInformation, as: LocInfo

  test "it works as a struct" do
    info = %LocInfo{}

    assert info.x_loc === 0.0
    assert info.y_loc === 0.0
    assert info.z_loc === 0.0

    assert info.object_id == 0
    assert info.heading == 0
    assert info.x_offset == 0
    assert info.y_offset == 0
    assert info.region == 0
    assert info.server_name == ""
  end

  test "it can create a binary" do
    {:ok, bin} =
      %LocInfo{x_loc: 40.5, y_loc: 55.55, z_loc: 22.891, object_id: 42}
      |> LocInfo.to_binary

    assert bin == <<0, 0, 34, 66, 51, 51, 94, 66, 197, 32, 183, 65, 0, 42, 0, 0, 0, 0,
                  0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "it can be created from a binary" do
    {:ok, info} =
      <<0, 0, 34, 66, 51, 51, 94, 66, 197, 32, 183, 65, 0, 42, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
        |> LocInfo.from_binary

    assert_in_delta info.x_loc, 40.5, 0.001
    assert_in_delta info.y_loc, 55.55, 0.001
    assert_in_delta info.z_loc, 22.891, 0.001
  end
end
