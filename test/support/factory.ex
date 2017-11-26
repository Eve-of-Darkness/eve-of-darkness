defmodule EOD.Repo.Factory do
  use ExMachina.Ecto, repo: EOD.Repo
  alias EOD.Repo.{Account}

  def account_factory do
    %Account{
      username: sequence(:uname, &"username_#{&1}"),
      password: Comeonin.Pbkdf2.hashpwsalt("test-password")
    }
  end
end
