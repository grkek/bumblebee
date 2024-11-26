defmodule Bumblebee.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BumblebeeWeb.Telemetry,
      Bumblebee.Repo,
      {DNSCluster, query: Application.get_env(:bumblebee, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Bumblebee.PubSub},
      # Start a worker by calling: Bumblebee.Worker.start_link(arg)
      # {Bumblebee.Worker, arg},
      # Start to serve requests, typically the last entry
      BumblebeeWeb.Endpoint,
      Bumblebee.PipelineController,
      {Membrane.RTMPServer,
       [
         handler: %Membrane.RTMP.Source.ClientHandlerImpl{controlling_process: self()},
         port: 1935,
         use_ssl?: false,
         handle_new_client: &Bumblebee.PipelineController.handle_new_client/3,
         client_timeout: 5_000
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bumblebee.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BumblebeeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
