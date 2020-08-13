defmodule Igwet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :igwet,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      aliases: aliases(),
      deps: deps(),
      default_task: "phx.server"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Igwet.Application, []},
      extra_applications: [:ueberauth, :ueberauth_auth0, :logger, :runtime_tools, :ex_twilio] #:ssl,
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, ">= 1.5.3"},
#      {:phoenix_pubsub, ">= 2.0.0"},
      {:phoenix_ecto, ">= 4.1.0"},
      {:postgrex, ">= 0.15.5"},
      {:phoenix_html, ">= 2.10.0"},
      {:phoenix_live_reload, ">= 1.2.4", only: :dev},
      {:libcluster, ">= 3.2.1"},
      {:distillery, ">= 2.1.1", runtime: false},
      {:gettext, ">= 0.11.0"},
      {:cowboy, ">= 2.8.0"},
      {:ueberauth, ">= 0.4.0"},
      {:ueberauth_auth0, ">= 0.3.0"},
      {:address_us, ">= 0.4.0"},
      {:csv, ">= 2.3.1"},
      {:bamboo, ">= 1.5.0"},
      {:plug_cowboy, ">= 2.3.0"},
      {:ex_twilio, github: "danielberkompas/ex_twilio"},
      {:jason, ">= 1.2.1"},
      {:ecto_sql, ">= 3.4.5"},
      {:version_tasks, "~> 0.11.4"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "run priv/repo/seeds.exs", "test"],
      prod: ["cmd cd assets && npm run deploy && cd ..", "phx.digest", "distillery.release --env=prod"],
      deploy: ["version.up", "cmd git push gigalixir master", "cmd gigalixir open"]
    ]
  end
end
