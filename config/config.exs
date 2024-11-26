# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :bumblebee,
  ecto_repos: [Bumblebee.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :bumblebee, BumblebeeWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: BumblebeeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Bumblebee.PubSub,
  live_view: [signing_salt: "ETK3i0Z4"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :bumblebee, Bumblebee.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures the ExAWS
config :ex_aws,
  json_codec: Jason,
  region: {:system, "AWS_REGION"},
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

# Configure the Guardian
config :bumblebee, Bumblebee.Guardian,
  issuer: "Bumblebee GmbH",
  secret_key: System.get_env("SECRET") || "QQ(]BdZb=L-kxoIlefwiSW}X)'Z~4nnrbNptWrpr8v5-ScJyCC"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
