defmodule EOD.Packet.Server.LoginGrantedTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.LoginGranted

  test "it works as a struct" do
    req = %LoginGranted{}
    assert req.username == ""
    assert req.server_name == ""
    assert req.server_id == 5
    assert req.client_coloring == :standard_all_realm
  end

  test "it can generate a binary" do
    {:ok, bin} =
      %LoginGranted{
        username: "ben",
        server_name: "EOD",
        server_id: 9,
        client_coloring: :standard_pvp
      }
      |> LoginGranted.to_binary()

    assert bin == <<3, "ben", 3, "EOD", 9, 1, 0, 0>>
  end

  test "it can generate from a binary" do
    {:ok, req} =
      <<6, "donald", 8, "darkness", 66, 3, 0, 0>>
      |> LoginGranted.from_binary()

    assert req.username == "donald"
    assert req.server_name == "darkness"
    assert req.server_id == 66
    assert req.client_coloring == :standard_pve
  end
end
