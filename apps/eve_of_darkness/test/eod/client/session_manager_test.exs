defmodule EOD.Client.SessionManagerTest do
  use EOD.RepoCase, async: true
  alias EOD.Client.SessionManager, as: SM

  setup tags do
    {:ok, manager} =
      if tags[:id_pool] do
        start_supervised({SM, id_pool: tags[:id_pool]})
      else
        start_supervised(SM)
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

  describe "registering an account with a client" do
    setup tags do
      account = build(:account, username: tags[:username] || "dudemanbro")
      {:ok, :registered} = SM.register_account(tags[:manager], account)
      {:ok, account: account}
    end

    test "prevents multiple dissimilar accounts", %{manager: manager} do
      assert {:error, :registered_as_different_account} ==
               SM.register_account(manager, build(:account, username: "rofldog"))
    end

    test "allows multiple same account registrations", %{manager: manager, account: acct} do
      assert {:ok, :registered} = SM.register_account(manager, acct)
    end

    test "prevents different clients from using same account", %{manager: manager, account: acct} do
      assert {:error, :account_already_registered} ==
               fn -> SM.register_account(manager, acct) end
               |> Task.async()
               |> Task.await()
    end

    test "can get a MapSet of registered accounts", %{manager: manager} do
      accounts = SM.accounts_registered(manager)
      assert MapSet.member?(accounts, "dudemanbro")
    end

    test "getting multiple clients by accounts at a time", %{manager: manager} do
      clients = SM.clients_by_accounts(manager, ~w(dudemanbro jimmyjones))
      assert {:ok, "dudemanbro", self()} in clients
      assert {:error, :not_found, "jimmyjones"} in clients
    end

    test "registered accounts automatically are reaped", %{manager: manager} do
      acct = build(:account, username: "rofls")

      task =
        Task.async(fn ->
          SM.register_account(manager, acct)
          manager |> SM.accounts_registered() |> MapSet.member?("rofls")
        end)

      assert Task.await(task)
      refute manager |> SM.accounts_registered() |> MapSet.member?("rofls")
    end
  end
end
