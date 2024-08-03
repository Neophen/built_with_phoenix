# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :built_with_phoenix,
  ecto_repos: [BuiltWithPhoenix.Repo],
  generators: [timestamp_type: :utc_datetime]

# Ash
config :built_with_phoenix,
  ash_domains: [BuiltWithPhoenix.Organizations, BuiltWithPhoenix.Accounts]

# S3 bucket config
config :built_with_phoenix,
  access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY"),
  bucket: System.fetch_env!("S3_BUCKET_NAME"),
  region: System.fetch_env!("AWS_REGION"),
  token_signing_secret: System.fetch_env!("TOKEN_SIGNING_SECRET")

# Configures the endpoint
config :built_with_phoenix, BuiltWithPhoenixWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: BuiltWithPhoenixWeb.ErrorHTML, json: BuiltWithPhoenixWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: BuiltWithPhoenix.PubSub,
  live_view: [signing_salt: "FC2Vd9mL"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :built_with_phoenix, BuiltWithPhoenix.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  built_with_phoenix: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  built_with_phoenix: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
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
