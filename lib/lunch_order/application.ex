defmodule LunchOrder.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(LunchOrder.Repo, []),
      # Start the endpoint when the application starts
      supervisor(LunchOrderWeb.Endpoint, []),
      # Start your own worker by calling: LunchOrder.Worker.start_link(arg1, arg2, arg3)
      # worker(LunchOrder.Worker, [arg1, arg2, arg3]),

      worker(LunchOrder.Scheduler, []),
      worker(Guardian.DB.Token.SweeperServer, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LunchOrder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LunchOrderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
