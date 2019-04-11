defmodule EOD.Web.ClientView do
  def render("index.json", %{clients: clients}) do
    %{data: clients}
  end
end
