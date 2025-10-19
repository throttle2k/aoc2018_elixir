defmodule Day17.ReservoirResearchTest do
  use ExUnit.Case, async: true
  alias Day17.ReservoirResearch

  test "part1 - count tiles with water" do
    input = """
    x=495, y=2..7
    y=7, x=495..501
    x=501, y=3..7
    x=498, y=2..4
    x=506, y=1..2
    x=498, y=10..13
    x=504, y=10..13
    y=13, x=498..504
    """

    assert ReservoirResearch.part1_with_input(input) == 57
  end

  test "part2 - count tiles with still water" do
    input = """
    x=495, y=2..7
    y=7, x=495..501
    x=501, y=3..7
    x=498, y=2..4
    x=506, y=1..2
    x=498, y=10..13
    x=504, y=10..13
    y=13, x=498..504
    """

    assert ReservoirResearch.part2_with_input(input) == 29
  end
end
