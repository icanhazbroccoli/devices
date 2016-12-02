defmodule EmitterDatasetProducerTest do
  use ExUnit.Case, async: true
  import Emitter.Dataset.Producer, only: [produce_events: 3]

  test "produce_events when demand is in the set" do
    events= [1,2,3,4,5,6,7,8,9,10]
    demand= 5
    assert { 5, [1,2,3,4,5] } == produce_events(demand, events, 0)
  end

  test "produce_events when demand is out of the set" do
    events= [1,2,3,4,5,6,7,8,9,10]
    demand= 10
    ptr= 3
    assert { 3, [4,5,6,7,8,9,10,1,2,3] } == produce_events(demand, events, ptr)
  end

  test "produce_events duplicates the set" do
    assert {0, [1,1,1,1,1]} == produce_events(5, [1], 0)
    assert {0, [1,1,1,1,1]} == produce_events(5, [1], 1)
  end

end

