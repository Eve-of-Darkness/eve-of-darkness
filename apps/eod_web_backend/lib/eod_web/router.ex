defmodule EOD.Web.Router do
  use EOD.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EOD.Web do
    pipe_through :api
    get "/clients", ClientController, :index
  end
end
