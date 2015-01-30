use Mix.Config

config :whenbus, Whenbus.Endpoint,
  http: [port: System.get_env("PORT") || 4001]

config :whenbus, Whenbus.Repo,
  database: "whenbustest",
  size: 1,
  max_overflow: 0

# Print only warnings and errors during test
config :logger, level: :warn
