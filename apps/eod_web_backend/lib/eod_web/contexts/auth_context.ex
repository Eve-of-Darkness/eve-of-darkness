defmodule EOD.Web.AuthContext do
  @moduledoc """
  The authentication for the web service shares the same auth as the
  game server in terms of username and password.  This module ensures
  web requests that authenticate share that functionality.
  """

  alias EOD.Repo
  alias EOD.Repo.Account

  def find_and_verify_account_password(%{"username" => username, "password" => password}) do
    account = Account.find_by_username(username) |> Repo.one()

    if Account.correct_password?(account, password) do
      {:ok, account}
    else
      {:error, :bad_username_or_password}
    end
  end

  def find_and_verify_account_password(_) do
    {:error, :missing_username_or_password}
  end
end
