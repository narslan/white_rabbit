defmodule WhiteRabbitTest do
  use ExUnit.Case
  doctest WhiteRabbit

  test "greets the world" do
    assert WhiteRabbit.hello() == :world
  end
end
