defmodule AmmoWeb.Router do
  use AmmoWeb, :router

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

  pipeline :heartbeat do
    plug :accepts, ~w|html json|
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  ##############################################################################

  scope "/auth", AmmoWeb do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  scope "/api", AmmoWeb.Api, as: :api  do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      resources "/albums", AlbumsController, only: [:index, :update, :create, :show, :delete] do
      end

      resources "/photos", PhotosController, only: [:index, :show, :create] do
      end
    end
  end

  scope "/heartbeat", AmmoWeb, as: :heartbeat  do
    pipe_through :heartbeat

    get "/", PageController, :heartbeat
  end

  ##############################################################################

  scope "/", AmmoWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AmmoWeb do
  #   pipe_through :api
  # end
end
