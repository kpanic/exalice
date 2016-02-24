defmodule ExAlice do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(ExAlice.Worker, []),
      worker(ExAlice.StreamRunner, [4, [name: ExAlice.StreamRunner]])
    ]

    opts = [strategy: :one_for_one, name: ExAlice.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
