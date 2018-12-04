defmodule DuckDuckTest do
  use ExUnit.Case
  doctest DuckDuck

  test "greets the world" do
    assert DuckDuck.hello() == :world
  end
end
