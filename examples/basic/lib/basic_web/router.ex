defmodule BasicWeb.Router do
  use BasicWeb, :router
  import EctoStorageWeb, only: [blob_routes: 0]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BasicWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BasicWeb do
    pipe_through :browser

    live "/posts", PostLive.Index, :index
    live "/posts/new", PostLive.Form, :new
    live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/edit", PostLive.Form, :edit


    # EctoStorage blob routes
    blob_routes()
    get "/", PageController, :home
  end


  # Other scopes may use custom stacks.
  # scope "/api", BasicWeb do
  #   pipe_through :api
  # end
end
