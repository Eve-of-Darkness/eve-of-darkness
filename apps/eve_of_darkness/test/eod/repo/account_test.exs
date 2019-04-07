defmodule EOD.Repo.AccountTest do
  use EOD.RepoCase, async: true
  alias EOD.Repo.Account

  test "creating a new account" do
    assert {:ok, account} =
             %Account{}
             |> Account.changeset(%{username: "test", password: "somesilly password"})
             |> Repo.insert()

    assert account.password && byte_size(account.password) > 30
    refute account.password == "somesilly password"
    assert account.username == "test"
  end

  test "#correct_password?/2" do
    account =
      build(:account)
      |> Account.changeset(%{password: "testingpassword"})
      |> Ecto.Changeset.apply_changes()

    refute account.password == "testingpassword"
    assert Account.correct_password?(account, "testingpassword")
  end
end
