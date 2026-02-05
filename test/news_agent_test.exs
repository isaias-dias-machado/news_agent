defmodule NewsAgentTest do
  use ExUnit.Case
  doctest NewsAgent

  test "greets the world" do
    assert NewsAgent.hello() == :world
  end
end
