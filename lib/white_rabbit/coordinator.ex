defmodule WhiteRabbit.Coordinator do
  use GenServer
  alias WhiteRabbit.Store.ETS

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    ETS.start_link()

    {:ok, %{}}
  end

  @impl true
  def handle_cast({:insert, metric, ts, value}, state) do
    ETS.insert(metric, ts, value)
    {:noreply, state}
  end

  @impl true
  def handle_call({:get, metric, ts}, _from, state) do
    {:reply, ETS.get(metric, ts), state}
  end

  def insert(pid \\ __MODULE__, metric, ts, value) do
    GenServer.cast(pid, {:insert, metric, ts, value})
  end

  def get(pid \\ __MODULE__, metric, ts) do
    GenServer.call(pid, {:get, metric, ts})
  end
end
