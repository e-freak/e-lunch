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
    post "/login", PageController, :login
    get "/orderlist", PageController, :order_list
  end

  # Other scopes may use custom stacks.
  scope "/api", LunchOrderWeb do
    pipe_through :api

    post "/login", SessionController, :login



    # pipe_through :authenticated
    post "/orders/:user/:month", OrderController, :create

    get "/orders/:user/:month", OrderController, :show

    get "/orders/:date", OrderController, :show_all

    get "/users/info", UserController, :private

    # resources "/orders", OrderController, except: [:new, :edit]

    # pipe_through :authenticated
    resources "/users", UserController, except: [:new, :edit]

  end
end
