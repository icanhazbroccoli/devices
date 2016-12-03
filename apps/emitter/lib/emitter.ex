alias Experimental.GenStage

defmodule Emitter do
  use Application

  @max_cons 3

  def start(_type, args) do
    import Supervisor.Spec, warn: false
    cons= (0..@max_cons-1) |> Enum.map(fn ix -> String.to_atom "consumer_#{ix}" end)
    workers= cons |> Enum.map(fn con ->
      worker(Emitter.Dataset.Consumer, [con], [id: con])
    end)
    children= [
      worker(Emitter.Dataset.Producer, ["data.dat"]),
    ] ++ workers
    opts= [strategy: :one_for_one, name: Emitter.Supervisor]
    sup_status= Supervisor.start_link(children, opts)
    cons |> Enum.each(fn con ->
      case Process.whereis(con) do
        nil ->
          IO.puts "Cannot find process with id #{con}"
        pid -> 
          GenStage.sync_subscribe(pid, to: Emitter.Dataset.Producer, max_demand: 1)
      end
    end)
    sup_status
  end

end
