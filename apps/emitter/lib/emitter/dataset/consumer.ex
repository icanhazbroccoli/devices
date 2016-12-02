alias Experimental.GenStage

defmodule Emitter.Dataset.Consumer do
  use GenStage

  def start_link(name) do
    GenStage.start_link(__MODULE__, :ok, name: name)
  end

  def init(:ok) do
    {:consumer, :ok}
  end

  def handle_events(events, _from, state) do
    IO.inspect events
    :timer.sleep 1000
    {:noreply, [], state}
  end

end
