defmodule Order.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OrderWeb.Telemetry,
      Order.Repo,
      {DNSCluster, query: Application.get_env(:order, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Order.PubSub},
      Order.Organizations.Presence,
      Order.Meetings.Presence,
      # Start the Finch HTTP client for sending emails
      {Finch, name: Order.Finch},
      # Start a worker by calling: Order.Worker.start_link(arg)
      # {Order.Worker, arg},
      # Start to serve requests, typically the last entry
      OrderWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Order.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
