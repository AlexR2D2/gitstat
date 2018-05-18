use Mix.Config

# Do not print debug messages in production
# config :logger, level: :info

config :logger,
  compile_time_purge_level: :error,
  level: :error
