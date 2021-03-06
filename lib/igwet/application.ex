defmodule Igwet.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Igwet.Repo, []),
      # Start the endpoint when the application starts
      supervisor(IgwetWeb.Endpoint, []),
      # Start your own worker by calling: Igwet.Worker.start_link(arg1, arg2, arg3)
      # worker(Igwet.Worker, [arg1, arg2, arg3]),
      {Phoenix.PubSub, [name: Igwet.PubSub, adapter: Phoenix.PubSub.PG2]},
      # At scale, need to keep Timezones up to date
      # Commented out to avoid crashes when running offline during test
      # {Tz.UpdatePeriodically, []}
      Igwet.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Igwet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    IgwetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
