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
end
