defmodule EOD.Region.ManagerTest do
  use EOD.RepoCase, async: true
  alias EOD.Region

  describe "when started up with no options" do
    setup _ do
      insert(:region_data, region_id: 51, name: "region051", description: "Area 51")
      {:ok, pid} = Region.Manager.start_link()
      {:ok, manager: pid}
    end

    test "you can get the region ids that are loaded", context do
      assert [51] == Region.Manager.region_ids(context.manager)
    end

    test "get_region/2 with valid region id", context do
      assert {:ok, pid} = Region.Manager.get_region(context.manager, 51)
      assert is_pid(pid)
      assert 51 = Region.region_id(pid)
    end

    test "get_region/2 with invalid region id", context do
      assert {:error, :no_region} == Region.Manager.get_region(context.manager, 55)
    end
  end
end
