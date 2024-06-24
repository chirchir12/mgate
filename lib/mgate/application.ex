defmodule Mgate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MgateWeb.Telemetry,
      Mgate.Repo,
      {DNSCluster, query: Application.get_env(:mgate, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Mgate.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Mgate.Finch},
      # Start a worker by calling: Mgate.Worker.start_link(arg)
      # {Mgate.Worker, arg},
      # Start to serve requests, typically the last entry
      Mgate.Gateway.TransferRegistry,
      Mgate.Gateway.TransferSupervisor,
      MgateWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mgate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MgateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
