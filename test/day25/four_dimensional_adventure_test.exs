defmodule Day25.FourDimensionalAdventureTest do
  use ExUnit.Case, async: true
  alias Day25.FourDimensionalAdventure

  test "part1 - count constellations 1" do
    input = """
    0,0,0,0
    3,0,0,0
    0,3,0,0
    0,0,3,0
    0,0,0,3
    0,0,0,6
    9,0,0,0
    12,0,0,0
    """

    assert FourDimensionalAdventure.part1_with_input(input) == 2
  end

  test "part1 - count constellations 2" do
    input = """
    -1,2,2,0
    0,0,2,-2
    0,0,0,-2
    -1,2,0,0
    -2,-2,-2,2
    3,0,2,-1
    -1,3,2,2
    -1,0,-1,0
    0,2,1,-2
    3,0,0,0
    """

    assert FourDimensionalAdventure.part1_with_input(input) == 4
  end

  test "part1 - count constellations 3" do
    input = """
    1,-1,0,1
    2,0,-1,0
    3,2,-1,0
    0,0,3,1
    0,0,-1,-1
    2,3,-2,0
    -2,2,0,0
    2,-2,0,-1
    1,-1,0,-1
    3,2,0,2
    """

    assert FourDimensionalAdventure.part1_with_input(input) == 3
  end

  test "part1 - count constellations 4" do
    input = """
    1,-1,-1,-2
    -2,-2,0,1
    0,2,1,3
    -2,3,-2,1
    0,2,3,-2
    -1,-1,1,-2
    0,-2,-1,0
    -2,2,3,-1
    1,2,2,0
    -1,-2,0,-2
    """

    assert FourDimensionalAdventure.part1_with_input(input) == 8
  end
end
