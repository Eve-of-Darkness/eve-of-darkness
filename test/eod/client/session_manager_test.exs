defmodule EOD.Client.SessionManagerTest do
  use ExUnit.Case, async: true
  alias EOD.Client.SessionManager, as: SM

  setup tags do
    {:ok, manager} =
      if tags[:id_pool] do
        SM.start_link(id_pool: tags[:id_pool])
      else
        SM.start_link()
      end

    {:ok, manager: manager}
  end

  test "starts fine with no parameters", %{manager: manager} do
    assert manager |> SM.amount_free() == 65_535
    assert manager |> SM.sessions_availale?()
  end

  @tag id_pool: [1, 2, 3]
  test "starts with custom pool size", %{manager: manager} do
    assert manager |> SM.amount_free() == 3
    assert manager |> SM.sessions_availale?()
  end

  @tag id_pool: []
  test "with an empty session pool", %{manager: manager} do
    assert manager |> SM.amount_free() == 0
    refute manager |> SM.sessions_availale?()
  end

  describe "registering with the session manager" do
    @tag id_pool: [1, 2, 3]
    test "grabbing one", %{manager: manager} do
      assert manager |> SM.amount_free() == 3
      assert {:ok, 1} = manager |> SM.register()
      assert manager |> SM.amount_free() == 2
    end

    @tag id_pool: [1, 2, 3]
    test "same process can't register twice", %{manager: manager} do
      assert {:ok, 1} = manager |> SM.register()
      assert {:ok, 1} = manager |> SM.register()
      assert manager |> SM.amount_free() == 2
    end

    @tag id_pool: [1, 2]
    test "processes can each grab their own session id", %{manager: manager} do
      assert {:ok, 1} = manager |> SM.register()
      task = Task.async(fn -> {:ok, 2} == manager |> SM.register() end)
      assert Task.await(task)
    end

    @tag id_pool: [1]
    test "session ids are reclaimed from stopped processes", %{manager: manager} do
      task = Task.async(fn -> {:ok, 1} == manager |> SM.register() end)
      assert Task.await(task)
      assert manager |> SM.amount_free() == 1
    end

    @tag id_pool: [1]
    test "get `{:error, :no_session}` when all sessions in use", %{manager: manager} do
      assert {:ok, 1} = manager |> SM.register()
      task = Task.async(fn -> manager |> SM.register() end)
      assert {:error, :no_session} = Task.await(task)
    end
  end
end
