defmodule WhiteRabbitTest do
  use ExUnit.Case
  doctest WhiteRabbit

  setup do
    {:ok, pid} = WhiteRabbit.Coordinator.start_link()
    %{pid: pid}
  end

  describe "deterministic tests" do
    test "insert and get a single metric value", %{pid: pid} do
      ts = 1_695_000_000
      :ok = WhiteRabbit.insert(pid, "cpu_usage", ts, 87.5)
      assert {:ok, 87.5} = WhiteRabbit.get(pid, "cpu_usage", ts)
    end

    test "returns :not_found for missing data", %{pid: pid} do
      assert :not_found = WhiteRabbit.get(pid, "cpu_usage", 12345)
    end
  end

  describe "dynamic tests with real system data" do
    test "stores process memory usage", %{pid: pid} do
      ts = System.system_time(:second)
      {:memory, mem} = Process.info(self(), :memory)

      WhiteRabbit.insert(pid, "proc_mem", ts, mem)
      assert {:ok, val} = WhiteRabbit.get(pid, "proc_mem", ts)
      assert is_integer(val)
    end

    test "stores system process count", %{pid: pid} do
      ts = System.system_time(:second)
      count = :erlang.system_info(:process_count)

      WhiteRabbit.insert(pid, "proc_count", ts, count)
      assert {:ok, val} = WhiteRabbit.get(pid, "proc_count", ts)
      assert is_integer(val)
      assert val > 0
    end
  end

  describe "range tests" do
    test "range returns points in interval", %{pid: pid} do
      metric = "cpu"
      now = System.system_time(:second)
      WhiteRabbit.insert(pid, metric, now - 10, 1.0)
      WhiteRabbit.insert(pid, metric, now - 5, 2.0)
      WhiteRabbit.insert(pid, metric, now + 1, 3.0)

      result = WhiteRabbit.range(metric, now - 20, now)
      assert result == [{now - 10, 1.0}, {now - 5, 2.0}]
    end

    test "range_agg avg works", %{pid: pid} do
      metric = "cpu_avg"
      now = System.system_time(:second)
      WhiteRabbit.insert(pid, metric, now, 2)
      WhiteRabbit.insert(pid, metric, now + 1, 4)

      assert WhiteRabbit.range_agg(metric, now, now + 1, :avg) == 3.0
    end
  end
end
