defmodule EOD.RegionTest do
  use EOD.RepoCase, async: true
  alias EOD.Region

  test "It can be started up under a name scheme" do
    data = build(:region_data)
    {:ok, pid} = Region.start_link(data, name: :region_roflcopters)
    assert :region_roflcopters in Process.registered
    assert Process.whereis(:region_roflcopters) == pid
  end
end
