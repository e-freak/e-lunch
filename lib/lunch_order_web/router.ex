defmodule LunchOrderWeb.Router do
  use LunchOrderWeb, :router

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

  pipeline :authenticated do
    plug LunchOrder.Guardian.AuthPipeline
  end

  scope "/", LunchOrderWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", LunchOrderWeb do
    pipe_through :api

    post "/sign_in", SessionController, :sign_in

    pipe_through :authenticated
    resources "/users", UserController, except: [:new, :edit]
  end
end
