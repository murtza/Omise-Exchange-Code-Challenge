defmodule OmgTest do
  use ExUnit.Case
  doctest Omg

  test "greets the world" do
    assert Omg.hello() == :world
  end
end
