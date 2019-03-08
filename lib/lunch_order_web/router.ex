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

  pipeline :admin_authenticated do
    plug LunchOrder.AdminPipeline
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

    # ログイン後
    pipe_through :authenticated

    # この2つは管理者用だが、下に持って行くと、先に/orders/:userがマッチしてしまうので上に置いておく
    get "/orders/outline/:month", OrderController, :outline
    get "/orders/fax/:date", OrderController, :show_fax_data
    get "/orders/detail/:year_month", OrderController, :show_detail

    post "/orders/:user/:month", OrderController, :create
    get "/orders/:user/:month", OrderController, :show
    get "/orders/:date", OrderController, :show_all
    get "/users/info", UserController, :private

    resources "/users", UserController, only: [:index, :show, :update]

    get "/menus", MenuController, :index

    get "/holidays/:year_month", HolidayController, :show

    # 管理者用
    pipe_through :admin_authenticated

    resources "/users", UserController, only: [:create, :delete]

    post "/holidays/:year_month", HolidayController, :update




  end
end
