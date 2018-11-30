# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :lunch_order,
  ecto_repos: [LunchOrder.Repo]

# Configures the endpoint
config :lunch_order, LunchOrderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/JF0of3NA/Rrb+WA0w8nETEmoxiXwR+8N620Zpv30CiCNtt5Glzm8pc3QnR+hLbt",
  render_errors: [view: LunchOrderWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LunchOrder.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
