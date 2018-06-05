defmodule EOD.Packet.Server.EncumberanceTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.Encumberance

  test "it works as a struct" do
    encumberance = %Encumberance{}
    assert encumberance.max == 0
    assert encumberance.current == 0
  end

  test "it can create a binary" do
    {:ok, bin} =
      %Encumberance{max: 80, current: 30}
      |> Encumberance.to_binary()

    assert bin == <<0, 80, 0, 30>>
  end

  test "it can be created from a binary" do
    {:ok, msg} =
      <<1, 1, 0, 30>>
      |> Encumberance.from_binary()

    assert msg == %Encumberance{max: 257, current: 30}
  end
end
