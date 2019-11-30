# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :naive_dice,
  stripe_pub_key: System.get_env("STRIPE_PUB_KEY")

config :stripity_stripe, api_key: System.get_env("STRIPE_SECRET")

config :naive_dice,
 stripe_api: NaiveDice.Services.Stripe.Api

config :naive_dice,
  ecto_repos: [NaiveDice.Repo]

# Configures the endpoint
config :naive_dice, NaiveDiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uxBDQyIVsLWH5ncwtbCTcGNr1I9ZncFcSEcoZJaiy1oqpx+MEiXIWlRZ9HdxQDae",
  render_errors: [view: NaiveDiceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NaiveDice.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Guardian
config :naive_dice, NaiveDice.Auth.Guardian,
  issuer: "naive_dice",
  secret_key: "HNinpKh9Ne3tr8BpjCpAEh0xzCqTIG3PWsfkR2AtzvUaRIpbs6oIQ9RcmjmGPekJ"

 config :naive_dice, NaiveDice.Auth.AuthAccessPipeline,
  module: NaiveDice.Auth.Guardian,
  error_handler: NaiveDice.Auth.AuthErrorHandler

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
