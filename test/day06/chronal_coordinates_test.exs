defmodule Day06.ChronalCoordinatesTest do
  use ExUnit.Case, async: true
  alias Day06.ChronalCoordinates

  test "part1 - largest not infinite area" do
    input = """
    1, 1
    1, 6
    8, 3
    3, 4
    5, 5
    8, 9
    """

    assert ChronalCoordinates.part1_with_input(input) == 17
  end

  test "part2 - points closer than 32 to all nodes" do
    input = """
    1, 1
    1, 6
    8, 3
    3, 4
    5, 5
    8, 9
    """

    assert ChronalCoordinates.part2_with_input(input, 32) == 16
  end
end
