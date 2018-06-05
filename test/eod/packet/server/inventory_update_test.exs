defmodule EOD.Packet.Server.InventoryUpdateTest do
  use ExUnit.Case, async: true
  alias EOD.Packet.Server.InventoryUpdate, as: InvUpdate
  alias InvUpdate.ItemData, as: Item

  defp to_binary_and_back(update) do
    {:ok, bin} = InvUpdate.to_binary(update)
    {:ok, back} = InvUpdate.from_binary(bin)
    back
  end

  test "it works as a struct" do
    update = %InvUpdate{}
    assert update.item_count == 0
    assert update.cloak_visible? == true
    assert update.helm_visible? == true
    assert update.cloak_hood_up? == true
    assert update.active_quiver_slot == 0
    assert update.active_weapon == :none
    assert update.window_type == :update
    assert update.items == []
  end

  test "cloak visible flag works back and forth" do
    assert %InvUpdate{cloak_visible?: false} ==
             %InvUpdate{cloak_visible?: false} |> to_binary_and_back()
  end

  test "helm visible flag works back and forth" do
    assert %InvUpdate{helm_visible?: false} ==
             %InvUpdate{helm_visible?: false} |> to_binary_and_back()
  end

  test "helm cloak hood up flag works back and forth" do
    assert %InvUpdate{cloak_hood_up?: false} ==
             %InvUpdate{cloak_hood_up?: false} |> to_binary_and_back()
  end

  test "active quiver slot works back and forth" do
    assert %InvUpdate{active_quiver_slot: 4} ==
             %InvUpdate{active_quiver_slot: 4} |> to_binary_and_back()
  end

  test "an item can go back and forth" do
    assert %InvUpdate{items: [%Item{name: "foo"}]} ==
             %InvUpdate{items: [%Item{name: "foo"}]} |> to_binary_and_back()
  end
end
