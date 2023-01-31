defmodule ApiCommonsTest do
  use ExUnit.Case
  doctest ApiCommons

  test "greets the world" do
    assert ApiCommons.hello() == :world
  end
end
