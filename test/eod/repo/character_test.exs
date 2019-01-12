defmodule EOD.Repo.CharacterTest do
  use EOD.RepoCase, async: true
  alias EOD.Repo.Character

  test "#find_by_name" do
    insert(:character, name: "Bigben")
    assert Character.name_taken?("bigben")
    refute Character.name_taken?("thewhat")
  end

  describe "#for_realm" do
    setup tags do
      alb = insert(:character, name: "benfalk", realm: 1)
      mid = insert(:character, name: "ryno", realm: 2)
      hib = insert(:character, name: "lucas", realm: 3)

      {:ok,
       result:
         Character.for_realm(tags[:realm])
         |> Repo.all()
         |> Enum.map(& &1.id),
       alb: alb,
       mid: mid,
       hib: hib}
    end

    @tag realm: :albion
    test ":albion only finds albs", context do
      assert context.alb.id in context.result
      refute context.mid.id in context.result
      refute context.hib.id in context.result
    end

    @tag realm: :midgard
    test ":midgard only finds mids", context do
      assert context.mid.id in context.result
      refute context.alb.id in context.result
      refute context.hib.id in context.result
    end

    @tag realm: :hibernia
    test ":hibernia only finds hibs", context do
      assert context.hib.id in context.result
      refute context.alb.id in context.result
      refute context.mid.id in context.result
    end

    @tag realm: :none
    test ":none finds nothing", context do
      assert context.result |> Enum.count() == 0
    end
  end

  test "#invalid_name?" do
    import Character, only: [invalid_name?: 1]
    assert invalid_name?("te")
    refute invalid_name?("ted")
    assert invalid_name?("ted and bill")
    assert invalid_name?("areallybignamethatgoesovertwenty")
    assert invalid_name?("snowman" <> <<0xE2, 0x98, 0x83>>)
  end

  test "#for_account" do
    alb = insert(:character, name: "benfalk", realm: 1)
    mid = insert(:character, name: "ryno", realm: 2)

    result =
      Character.for_account(alb.account)
      |> Repo.all()
      |> Enum.map(& &1.id)

    assert alb.id in result
    refute mid.id in result
  end
end
