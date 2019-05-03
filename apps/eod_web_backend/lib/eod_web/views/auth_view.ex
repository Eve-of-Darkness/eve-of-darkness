defmodule EOD.Web.AuthView do
  def render("show.json", %{token: token}) do
    %{token: token}
  end

  def render("info.json", %{user: user}) do
    %{data: %{name: user.username, avatar: ''}}
  end
end
