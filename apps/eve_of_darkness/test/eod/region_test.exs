defmodule EOD.RegionTest do
  use EOD.RepoCase, async: true
  alias EOD.Region

  test "It can be started up under a name scheme" do
    data = build(:region_data)
    {:ok, pid} = Region.start_link(data, name: :region_roflcopters)
    assert :region_roflcopters in Process.registered()
    assert Process.whereis(:region_roflcopters) == pid
  end

  test "region_id/1 retreives the region's id" do
    data = build(:region_data, region_id: 99)
    {:ok, pid} = Region.start_link(data)
    assert 99 = Region.region_id(pid)
  end

  test "get_data/1 retreives RegionData" do
    data = build(:region_data)
    {:ok, pid} = Region.start_link(data)
    assert data == Region.get_data(pid)
  end

  test "get_overview/1" do
    data = build(:region_data, name: "rofl", region_id: 99)
    {:ok, pid} = Region.start_link(data, ip_address: "192.168.1.1", tcp_port: 10_300)
    overview = Region.get_overview(pid)
    assert overview.region_id == 99
    assert overview.name == "rofl"
    assert overview.ip_address == "192.168.1.1"
    assert overview.tcp_port == 10_300
  end
end
