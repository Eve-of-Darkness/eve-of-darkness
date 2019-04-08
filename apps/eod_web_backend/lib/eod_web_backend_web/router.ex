defmodule EOD.WebWeb.Router do
  use EOD.WebWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EOD.WebWeb do
    pipe_through :api
  end
end
