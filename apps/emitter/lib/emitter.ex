defmodule Emitter do
  use Application

  def start(_type, args) do
    import Supervisor.Spec, warn: false
    children= [
      worker(Emitter.Dataset, [args]),
      worker(Emitter.Socket,  [args]),
    ]
    opts= [strategy: :one_for_one, name: Emitter.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
