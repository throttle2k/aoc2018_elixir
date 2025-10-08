defmodule Day08.MemoryManeuverTest do
  use ExUnit.Case, async: true
  alias Day08.MemoryManeuver

  test "part1 - sum of metadata" do
    input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"

    assert MemoryManeuver.part1_with_input(input) == 138
  end

  test "part2 - sum of root" do
    input = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"

    assert MemoryManeuver.part2_with_input(input) == 66
  end
end
