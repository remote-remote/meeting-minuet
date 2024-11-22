defmodule MeetingMinuet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MeetingMinuetWeb.Telemetry,
      MeetingMinuet.Repo,
      {DNSCluster, query: Application.get_env(:meeting_minuet, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MeetingMinuet.PubSub},
      MeetingMinuet.Organizations.Presence,
      MeetingMinuet.Meetings.Presence,
      # Start the Finch HTTP client for sending emails
      {Finch, name: MeetingMinuet.Finch},
      # Start a worker by calling: MeetingMinuet.Worker.start_link(arg)
      # {MeetingMinuet.Worker, arg},
      # Start to serve requests, typically the last entry
      MeetingMinuetWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MeetingMinuet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MeetingMinuetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
