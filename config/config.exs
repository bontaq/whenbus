# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :whenbus, Whenbus.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iv5TemZp6kFt6C/14cZGWw1kfRIHnKeTvredwXGDCXOpX804oxmkPpJWOIjzRWfc",
  debug_errors: false

# Configure the database
config :whenbus, Whenbus.Repo,
  database: "whenbus",
  username: "Jack",
  password: "",
  hostname: "localhost"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
