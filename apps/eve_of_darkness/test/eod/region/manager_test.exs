defmodule EOD.Region.ManagerTest do
  use EOD.RepoCase, async: true
  alias EOD.Region
  alias Region.Manager

  describe "when started up with minimal options" do
    setup _ do
      insert(:region_data, region_id: 51, name: "region051", description: "Area 51")
      # Can't start supervised here because it won't share the same transaction above
      # and therefore won't find any regions when started without options
      {:ok, pid} = Manager.start_link(ip_address: "192.168.1.111", tcp_port: 10_300)
      {:ok, manager: pid}
    end

    test "you can get the region ids that are loaded", context do
      assert [51] == Manager.region_ids(context.manager)
    end

    test "get_region/2 with valid region id", context do
      assert {:ok, pid} = Manager.get_region(context.manager, 51)
      assert is_pid(pid)
      assert 51 = Region.region_id(pid)
    end

    test "get_region/2 with invalid region id", context do
      assert {:error, :no_region} == Manager.get_region(context.manager, 55)
    end

    test "it passes through the ip_address and port to each region", context do
      assert {:ok, pid} = Manager.get_region(context.manager, 51)
      assert overview = Region.get_overview(pid)
      assert overview.ip_address == "192.168.1.111"
      assert overview.tcp_port == 10_300
    end
  end

  describe "starting with all options" do
    @name {:via, Registry, {EOD.Server.Registry, :region_manager}}

    setup _ do
      insert(:region_data, region_id: 51, name: "region051", description: "Area 51")
      another = build(:region_data, region_id: 420, name: "region420", description: "Baked")

      opts = [
        ip_address: "192.168.1.123",
        tcp_port: 10_300,
        regions: [another],
        name: @name
      ]

      {:ok, _} = Manager.start_link(opts)
      :ok
    end

    test "it only has the regions loaded passed to it and can be referenced by name" do
      assert [420] = Manager.region_ids(@name)
    end
  end
end
