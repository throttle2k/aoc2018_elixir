defmodule Day07.TheSumOfItsPartsTest do
  use ExUnit.Case, async: true
  alias Day07.TheSumOfItsParts.{Part1, Part2}

  test "part1 - order of instructions" do
    input = """
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """

    assert Part1.part1_with_input(input) == "CABDFE"
  end

  test "part2 - order of instructions" do
    input = """
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """

    assert Part2.part2_with_input(input, 2, 0) == 15
  end
end
