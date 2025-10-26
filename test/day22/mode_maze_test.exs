defmodule Day22.ModeMazeTest do
  use ExUnit.Case, async: true
  alias Day22.ModeMaze

  test "part1 total risk" do
    input = """
    depth: 510
    target: 10,10
    """

    assert ModeMaze.part1(input) == 114
  end

  test "part2 fewest minutes to reach target" do
    input = """
    depth: 510
    target: 10,10
    """

    assert ModeMaze.part2(input) == 45
  end
end
