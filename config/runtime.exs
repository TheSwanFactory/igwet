# Adapted for Gigalixir from https://github.com/fly-apps/hello_elixir/blob/main/config/runtime.exs

import Config

# Shared Globals

database_url = System.get_env("DATABASE_URL") || raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base = System.get_env("SECRET_KEY_BASE") || raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """


# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.

#
# Development environment
#

if config_env() == :dev do
  config :igwet, Igwet.Repo, url: database_url, socket_options: [:inet6]

  config :igwet, IgwetWeb.Endpoint,
    url: [host: "localhost", port: "4000"],
    secret_key_base: secret_key_base
  config :igwet, IgwetWeb.Endpoint, server: true
end

# The block below contains prod specific runtime configuration.
if config_env() == :prod do

  app_name = System.get_env("APP_NAME") || raise "APP_NAME not available"

  config :igwet, Igwet.Repo,
    # ssl: true,
    # IMPORTANT: Or it won't find the DB server
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.

  config :igwet, IgwetWeb.Endpoint,
    url: [host: app_name <> ".gigalixirapp.com", port: 443],
    secret_key_base: secret_key_base

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  config :igwet, IgwetWeb.Endpoint, server: true

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :igwet, Igwet.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
