defmodule EOD.Packet.Server.Realm.Test do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.Realm

  test "it works as a struct" do
    req = %Realm{}
    assert req.realm == :none
  end

  test "it can convert from a binary" do
    {:ok, req} = <<2::8>> |> Realm.from_binary()
    assert req.realm == :midgard
  end

  test "it can convert to a binary" do
    assert {:ok, <<1::8>>} == %Realm{realm: :albion} |> Realm.to_binary()
  end
end
