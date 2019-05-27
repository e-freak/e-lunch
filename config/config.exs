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
  secret_key_base: "uYpqNsrxap7BKpN3TkwImvqvev1DI6mLu035P9+Pl9g1S7TN4HjnciJkSkTDUsgB",
  render_errors: [view: LunchOrderWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LunchOrder.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
# config :logger, :console,
#   format: "$time $metadata[$level] $message\n",
#   metadata: [:user_id]

config :logger,
  backends: [{LoggerFileBackend, :file}]

config :logger, :file,
  format: "$date $time $metadata[$level] $message\n",
  path: "log/e-lunch.log",
  level: :error



# COnfigures Guardian
config :lunch_order, LunchOrder.Guardian,
  issuer: "lunch_order",
  secret_key: "pHl6RIeQmZS/JOT/osu76pTE3+O3pXGPq74PgLqDUBGzei4cStZDvzpOTJ/emkd6"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
