defmodule EOD.Packet.Client.ClosingConnectionTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Client.ClosingConnection

  test "it works as a struct" do
    msg = %ClosingConnection{}
    assert msg.reason == 1
  end

  test "it can create a binary" do
    {:ok, bin} =
      %ClosingConnection{reason: 4}
      |> ClosingConnection.to_binary()

    assert bin == <<4>>
  end

  test "it can create a struct from a binary" do
    {:ok, msg} = <<5>> |> ClosingConnection.from_binary()
    assert msg == %ClosingConnection{reason: 5}
  end
end
