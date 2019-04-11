defmodule EOD.Web.Router do
  use EOD.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EOD.Web do
    pipe_through :api
  end
end
