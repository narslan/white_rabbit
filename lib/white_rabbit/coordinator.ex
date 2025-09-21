defmodule WhiteRabbit.Coordinator do
  use GenServer
  alias WhiteRabbit.Store.ETS

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, :white_rabbit)
    GenServer.start_link(__MODULE__, opts, name: name)
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

  def handle_call({:range, metric, from_ts, to_ts}, _from, state) do
    result = WhiteRabbit.Store.ETS.range(metric, from_ts, to_ts)
    {:reply, result, state}
  end

  def handle_call({:range_agg, metric, from_ts, to_ts, agg}, _from, state) do
    result = WhiteRabbit.Store.ETS.range_agg(metric, from_ts, to_ts, agg)
    {:reply, result, state}
  end

  def insert(pid \\ __MODULE__, metric, ts, value) do
    GenServer.cast(pid, {:insert, metric, ts, value})
  end

  def get(pid \\ __MODULE__, metric, ts) do
    GenServer.call(pid, {:get, metric, ts})
  end

  def range(pid \\ __MODULE__, metric, from_ts, to_ts),
    do: GenServer.call(pid, {:range, metric, from_ts, to_ts})

  def range_agg(pid \\ __MODULE__, metric, from_ts, to_ts, agg),
    do: GenServer.call(pid, {:range_agg, metric, from_ts, to_ts, agg})
end
