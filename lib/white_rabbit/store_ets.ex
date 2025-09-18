defmodule WhiteRabbit.Store.ETS do
  @table :timeseries

  def start_link do
    # falls Tabelle schon existiert, nichts tun (hilfreich beim Test)
    case :ets.whereis(@table) do
      :undefined ->
        :ets.new(@table, [:named_table, :public, :ordered_set])
        :ok

      _pid_or_table ->
        :ok
    end

    {:ok, self()}
  end

  def insert(metric, ts, value) do
    :ets.insert(@table, {{metric, ts}, value})
    :ok
  end

  def get(metric, ts) do
    case :ets.lookup(@table, {metric, ts}) do
      [{{^metric, ^ts}, value}] -> {:ok, value}
      [] -> :not_found
    end
  end

  @doc """
  Return list of {ts, value} for metric where from_ts <= ts <= to_ts.
  Results are sorted by timestamp asc.
  """
  def range(metric, from_ts, to_ts) do
    # match_spec: {{metric, TsVar}, ValueVar}, guard TsVar >= from_ts and <= to_ts, return {TsVar, ValueVar}
    match_spec = [
      {
        {{metric, :"$1"}, :"$2"},
        [
          {:>=, :"$1", from_ts},
          {:"=<", :"$1", to_ts}
        ],
        [{{:"$1", :"$2"}}]
      }
    ]

    :ets.select(@table, match_spec)
    |> Enum.sort_by(fn {ts, _val} -> ts end)
  end

  @doc """
  Simple aggregation over range: :count, :sum, :avg, :min, :max
  """
  def range_agg(metric, from_ts, to_ts, :count) do
    range(metric, from_ts, to_ts) |> length()
  end

  def range_agg(metric, from_ts, to_ts, :sum) do
    range(metric, from_ts, to_ts) |> Enum.reduce(0, fn {_, v}, acc -> acc + v end)
  end

  def range_agg(metric, from_ts, to_ts, :min) do
    range(metric, from_ts, to_ts) |> Enum.map(&elem(&1, 1)) |> Enum.min()
  end

  def range_agg(metric, from_ts, to_ts, :max) do
    range(metric, from_ts, to_ts) |> Enum.map(&elem(&1, 1)) |> Enum.max()
  end

  def range_agg(metric, from_ts, to_ts, :avg) do
    list = range(metric, from_ts, to_ts)

    case list do
      [] ->
        :no_data

      _ ->
        sum = Enum.reduce(list, 0, fn {_, v}, acc -> acc + v end)
        sum / length(list)
    end
  end
end
