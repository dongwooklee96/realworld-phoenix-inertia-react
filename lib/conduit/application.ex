defmodule Conduit.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ConduitWeb.Telemetry,
      Conduit.Repo,
      {DNSCluster, query: Application.get_env(:conduit, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Conduit.PubSub},
      {Finch, name: Conduit.Finch},
      ConduitWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :conduit]}
    ]

    opts = [strategy: :one_for_one, name: Conduit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ConduitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
