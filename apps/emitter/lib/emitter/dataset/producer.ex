alias Experimental.GenStage

defmodule Emitter.Dataset.Producer do

  use GenStage

  def start_link(read_from) do
    GenStage.start_link(__MODULE__, read_from, name: __MODULE__)
  end

  def init(read_from) do
    data= case File.exists?(read_from) do
      true -> File.read!(read_from) 
      false -> raise "Unable to find file #{read_from}"
    end |> String.trim |> String.split("\n")
    {:producer, {data, 0}} 
  end

  def handle_demand(demand, {data, ptr}) do
    {new_ptr, events}= produce_events(demand, data, ptr)
    {:noreply, events, {data, new_ptr}}
  end

  def produce_events(demand, data, ptr), do: produce_events(demand, data, ptr, [])
  def produce_events(demand, data, ptr, result) when ptr >= length(data) do
    produce_events(demand, data, ptr - length(data), result)
  end
  def produce_events(0, _data, ptr, result), do: { ptr, result }
  def produce_events(demand, data, ptr, result) do
    new_ptr= ptr + Enum.min([length(data) - ptr, demand])
    produce_events(demand - (new_ptr - ptr), data, new_ptr, result ++ Enum.slice(data, ptr, new_ptr - ptr))
  end

end
