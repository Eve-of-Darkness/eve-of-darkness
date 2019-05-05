defmodule EOD.Web.Router do
  use EOD.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: EOD.Web.Guardian,
      error_handler: EOD.Web.Guardian

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug EOD.Web.Plug.CurrentUser
  end

  scope "/api", EOD.Web do
    pipe_through [:api, :auth]
    get "/clients", ClientController, :index
    get "/clients/:id", ClientController, :show

    # Authentication
    post "/auth/login", AuthController, :login
    post "/auth/logout", AuthController, :logout
    get "/auth/info", AuthController, :info
  end
end
