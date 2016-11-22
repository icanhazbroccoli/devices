defmodule AggregatorTimerTest do

  use ExUnit.Case
  alias Aggregator.Timer

  test "start_timer and stop_timer should return :ok, " do
    Timer.start_link(1)
    assert Timer.start_timer == :ok
    assert Timer.stop_timer == :ok
  end

  test "register_callback should return :ok" do
    Timer.start_link(1)
    assert Timer.register_callback(fn -> IO.puts "tick!" end) == :ok
  end


end
