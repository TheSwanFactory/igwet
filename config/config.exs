# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :igwet,
  ecto_repos: [Igwet.Repo],
  admin_user: "Ernest Prabhakar",
  seed_keys: [
    type: "com.igwet.predicate.type",
    in: "com.igwet.predicate.in",
    admin_group: "com.igwet.group.Site-Administrators",
    superuser: "com.igwet.contact.Ernest-Prabhakar"
  ]

# Configures the endpoint
config :igwet, IgwetWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YbvTQa/w6m9GwiFuVEp76H8MgaXGqh0G/1aMI+3w+QEqMM9Emilm3OKhEWPOXnfc",
  render_errors: [view: IgwetWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Igwet.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Ueberauth
config :ueberauth, Ueberauth,
  providers: [
    auth0: { Ueberauth.Strategy.Auth0, [] },
  ]

# Configures Ueberauth's Auth0 auth provider
config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: "${AUTH0_DOMAIN}",
  client_id: "${AUTH0_CLIENT_ID}",
  client_secret: "${AUTH0_CLIENT_SECRET}"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
