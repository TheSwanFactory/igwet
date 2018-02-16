defmodule IgwetWeb.Router do
  use IgwetWeb, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IgwetWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/logout", AuthController, :logout
    resources "/users", UserController
    resources "/nodes", NodeController
    resources "/edges", EdgeController
  end

  scope "/auth", IgwetWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

end
