defmodule IgwetWeb.Router do
  use IgwetWeb, :router

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
    resources "/nodes", NodeController
  end

  # Other scopes may use custom stacks.
  # scope "/api", IgwetWeb do
  #   pipe_through :api
  # end
end
