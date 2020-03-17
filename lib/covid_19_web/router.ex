defmodule Covid19Web.Router do
  use Covid19Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_live_layout, {Covid19Web.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Covid19Web do
    pipe_through :browser

    live "/", CovidLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", Covid19Web do
  #   pipe_through :api
  # end
end
