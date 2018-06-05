defmodule EOD.Packet.Server.PlayerSpeedTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.PlayerSpeed

  test "it works as a struct" do
    speed = %PlayerSpeed{}
    assert speed.max == 100
    assert speed.turning_disabled? == false
  end

  test "it can create a binary" do
    {:ok, bin} =
      %PlayerSpeed{max: 125, turning_disabled?: true}
      |> PlayerSpeed.to_binary()

    assert bin == <<0, 125, 1, 0>>
  end

  test "it can be created from a binary" do
    {:ok, msg} =
      <<0, 124, 1, 0>>
      |> PlayerSpeed.from_binary()

    assert msg == %PlayerSpeed{max: 124, turning_disabled?: true}
  end
end
