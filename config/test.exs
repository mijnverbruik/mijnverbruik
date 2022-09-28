import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :mijnverbruik, Mijnverbruik.Repo,
  database: Path.expand("../mijnverbruik_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mijnverbruik, MijnverbruikWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Ml8Rroe44cL9M/+7O0tKwuGWB3F919qGngoNZwMdvJSmsqEFBf7uF/vmdfw21PSO",
  server: false

# In test we don't read the meter values.
config :mijnverbruik, meter_enabled: false

# In test we don't send emails.
config :mijnverbruik, Mijnverbruik.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
