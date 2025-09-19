defmodule WhiteRabbit do
  alias WhiteRabbit.Coordinator

  @doc """
  Insert a value for a given metric and timestamp.
  """
  @spec insert(pid(), metric :: String.t(), ts :: integer, value :: number) :: :ok
  def insert(pid, metric, ts, value) do
    Coordinator.insert(pid, metric, ts, value)
  end

  @doc """
  Get a value for a given metric and timestamp.
  """
  @spec get(pid(), metric :: String.t(), ts :: integer) :: {:ok, number} | :not_found
  def get(pid, metric, ts) do
    Coordinator.get(pid, metric, ts)
  end

  def range(pid, metric, from_ts, to_ts),
    do: WhiteRabbit.Coordinator.range(pid, metric, from_ts, to_ts)

  def range_agg(pid, metric, from_ts, to_ts, agg),
    do: WhiteRabbit.Coordinator.range_agg(pid, metric, from_ts, to_ts, agg)
end
