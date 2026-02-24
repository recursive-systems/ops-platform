defmodule OpsPlatform.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OpsPlatformWeb.Telemetry,
      OpsPlatform.Repo,
      {DNSCluster, query: Application.get_env(:ops_platform, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OpsPlatform.PubSub},
      # Start a worker by calling: OpsPlatform.Worker.start_link(arg)
      # {OpsPlatform.Worker, arg},
      # Start to serve requests, typically the last entry
      OpsPlatformWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OpsPlatform.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OpsPlatformWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
