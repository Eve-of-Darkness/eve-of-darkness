defmodule EOD.Packet.Server.AssignSessionTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.AssignSession

  test "it has a session_id" do
    req = %AssignSession{}
    assert req.session_id == 0
  end

  test "it can create a binary" do
    {:ok, bin} =
      %AssignSession{session_id: 7}
      |> AssignSession.to_binary()

    assert bin == <<7, 0>>
  end

  test "it can read a binary" do
    {:ok, req} = <<230, 18>> |> AssignSession.from_binary()

    assert req.session_id == 4838
  end

  test "it's size is 16" do
    assert AssignSession.packet_size() == 2
  end
end
