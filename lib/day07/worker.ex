defmodule Day07.TheSumOfItsParts.Worker do
  use GenServer

  def start_link(duration \\ 60) do
    GenServer.start_link(__MODULE__, duration)
  end

  def tick(pid) do
    GenServer.call(pid, {:tick})
  end

  def get_status(pid) do
    GenServer.call(pid, {:get_status})
  end

  def start_step(pid, step) do
    GenServer.cast(pid, {:start_step, step})
  end

  @impl true
  def init(basic_duration) do
    {:ok, %{status: :idle, current_step: nil, duration: nil, basic_duration: basic_duration}}
  end

  @impl true
  def handle_call({:tick}, _from, state) do
    case state do
      %{status: :idle} ->
        {:reply, :idle, state}

      %{status: :working, duration: 1} ->
        {:reply, {:done, state.current_step},
         %{state | status: :idle, current_step: nil, duration: nil}}

      %{status: :working, duration: _} ->
        {:reply, :working, %{state | duration: state.duration - 1}}
    end
  end

  @impl true
  def handle_call({:get_status}, _from, state) do
    {:reply, state.status, state}
  end

  @impl true
  def handle_cast({:start_step, <<step>>}, state) do
    duration = step - ?A + 1 + state.basic_duration
    {:noreply, %{state | status: :working, current_step: <<step::utf8>>, duration: duration}}
  end
end
