defmodule Apms.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Apms.Repo,
      ApmsWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Apms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ApmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
