# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :guthub_watcher_web,
  namespace: GuthubWatcherWeb

# Configures the endpoint
config :guthub_watcher_web, GuthubWatcherWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wZzhtB/mdur7OhanQxTuauKrgc2bk/ysxEl7PZIqIjbHTyYmkaPDhz+Ua+tB66Gp",
  render_errors: [view: GuthubWatcherWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GuthubWatcherWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guthub_watcher_web, :generators,
  context_app: :guthub_watcher

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
