alias Experimental.GenStage

defmodule Emitter do
  use Application

  def start(_type, args) do
    import Supervisor.Spec, warn: false
    max_cons= 2
    cons= (0..max_cons) |> Enum.map(fn ix -> 
    name= "consumer_#{ix}" |> String.to_atom
      worker(Emitter.Dataset.Consumer, [name], [id: name])
    end)
    children= [
      worker(Emitter.Dataset.Producer, ["data.dat"]),
    ] ++ cons
    opts= [strategy: :one_for_one, name: Emitter.Supervisor]
    res= Supervisor.start_link(children, opts)
    (0..max_cons)
      |> Enum.each(fn ix ->
        pid= Process.whereis(String.to_atom("consumer_#{ix}"))
        GenStage.sync_subscribe(pid, to: Emitter.Dataset.Producer, max_demand: 1)
      end)
    res
  end

end
