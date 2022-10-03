# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :mijnverbruik,
  namespace: Mijnverbruik,
  ecto_repos: [Mijnverbruik.Repo]

# Configures the endpoint
config :mijnverbruik, MijnverbruikWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MijnverbruikWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Mijnverbruik.PubSub,
  live_view: [signing_salt: "/NMHKkBN"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :mijnverbruik, Mijnverbruik.Mailer, adapter: Swoosh.Adapters.Local

# Configure Elixir to use TZ as timezone database.
config :elixir, :time_zone_database, Tz.TimeZoneDatabase

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args: ~w(
      js/app.js
      --bundle
      --target=es2017
      --outdir=../priv/static/assets
      --external:/fonts/*
      --external:/images/*
    ),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
