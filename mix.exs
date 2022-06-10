defmodule Igwet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :igwet,
      version: "0.5.1",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      aliases: aliases(),
      deps: deps(),
      default_task: "phx.server"
      #releases: releases()
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
      {:address_us, ">= 0.4.0"},
      {:bamboo, ">= 1.5.0"},
      {:castore, "~> 0.1.5"},
      {:cowboy, ">= 2.8.0"},
      {:csv, ">= 2.3.1"},
      {:ecto_sql, ">= 3.4.5"},
      {:ex_twilio, github: "danielberkompas/ex_twilio"},
      {:finch, "~> 0.12"},
      {:gettext, ">= 0.11.0"},
      {:jason, ">= 1.2.1"},
      {:libcluster, ">= 3.2.1"},
      {:mint, "~> 1.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:nimble_strftime, "~> 0.1.1"},
      {:parallel_stream, ">= 1.1.0", override: true},
      {:phoenix, ">= 1.5.3"},
      {:phoenix_ecto, ">= 4.1.0"},
      {:phoenix_html, ">= 2.10.0"},
      {:phoenix_live_reload, ">= 1.2.4", only: :dev},
      {:plug_cowboy, ">= 2.3.0"},
      {:postgrex, ">= 0.15.5"},
      {:quantum, "~> 3.0"},
      {:tz, "~> 0.10.0"},
      {:ueberauth, ">= 0.4.0"},
      {:ueberauth_auth0, ">= 0.3.0"},
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
      deploy: ["cmd git push gigalixir master", "cmd sleep 30 && gigalixir open", "cmd gigalixir ps"]
    ]
  end
end
