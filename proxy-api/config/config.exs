# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :booming_proxy, BoomingProxyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HfrzW4V9bEpOfuUGaCMybktFKGIy28jaSU5rtj2zErDy/xh5IoM1Y0yzsziifM01",
  render_errors: [view: BoomingProxyWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BoomingProxy.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :booming_proxy, :amqp,
  host: "localhost",
  port: "5672",
  user: "guest",
  pass: "guest"

config :booming_proxy, :queues,
  clients: "backend.clients",
  invoices: "backend.invoices"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
