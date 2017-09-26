defmodule BoomingProxy.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(BoomingProxyWeb.Endpoint, []),
      worker(BoomingProxy.QueueServer, [])
    ]

    opts = [strategy: :one_for_one, name: BoomingProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    BoomingProxyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
