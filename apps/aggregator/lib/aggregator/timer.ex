defmodule Aggregator.Timer do

  use GenServer

  @timer_state_normal  0
  @timer_state_stopped 1

  def start_link(interval) do
    GenServer.start_link(__MODULE__, %{ interval: interval, timer_state: @timer_state_stopped, callbacks: [], timer: nil } , name: __MODULE__)
  end

  def start_timer do
    GenServer.call(__MODULE__, { :timer, :start })
  end

  def stop_timer do
    GenServer.call(__MODULE__, { :timer, :stop })
  end

  def register_callback(cb) do
    GenServer.call(__MODULE__, {:register_callback, cb})
  end

  def handle_call({ :timer, :start }, _from, state= %{ timer_state: timer_state }) do
    case timer_state do
      @timer_state_normal ->
        { :reply, { :skip, "already running" }, state }
      _ ->
        Task.async(fn ->
          Process.send({:tick}, :ok, [])
        end)
        {:reply, :ok, Map.put(state, :timer_state, @timer_state_normal)}
    end
  end

  def handle_call({ :timer, :stop }, _from, state= %{ timer_state: timer_state, timer: timer }) do
    case timer do
      nil -> {}
      _ -> Process.cancel_timer(timer)
    end
    state= Map.put(state, :timer, nil)
    case timer_state do
      @timer_state_stopped -> { :reply, { :skip, "already stopped" }, state }
      _ -> { :reply, :ok, Map.put(state, :timer_state, @timer_state_stopped) }
    end
  end

  def handle_call({ :register_callback, callback }, _from, state= %{callbacks: callbacks}) do
    { :reply, :ok, Map.put(state, :callbacks, callbacks ++ [ callback ]) }
  end

  def handle_info(:tick, state= %{ callbacks: callbacks, interval: interval}) do
    IO.puts "tick"
    Task.async(fn ->
      Enum.each(callbacks, fn cb ->
        Task.async(fn ->
          cb.()
        end)
      end)
    end)
    timer= Process.send_after(self(), :tick, interval)
    {:noreply, Map.put(state, :timer, timer)}
  end

end
