defmodule BuiltWithPhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BuiltWithPhoenixWeb.Telemetry,
      BuiltWithPhoenix.Repo,
      {DNSCluster, query: Application.get_env(:built_with_phoenix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BuiltWithPhoenix.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BuiltWithPhoenix.Finch},
      # Start a worker by calling: BuiltWithPhoenix.Worker.start_link(arg)
      # {BuiltWithPhoenix.Worker, arg},
      # Start to serve requests, typically the last entry
      BuiltWithPhoenixWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BuiltWithPhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BuiltWithPhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
