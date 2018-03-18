use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :igwet, IgwetWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :igwet, Igwet.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "runner",
  password: "semaphoredb",
  database: "igwet_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure Bamboo for Test
config :igwet, Igwet.Admin.Mailer, adapter: Bamboo.TestAdapter
