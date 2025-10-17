defmodule Day15.BeverageBanditsTest do
  use ExUnit.Case, async: true
  alias Day15.BeverageBandits

  test "part1 - full round" do
    input = """
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
    """

    assert BeverageBandits.part1_with_input(input) == 27730
  end

  test "part1 - full round 2" do
    input = """
    #######
    #G..#E#
    #E#E.E#
    #G.##.#
    #...#E#
    #...E.#
    #######
    """

    assert BeverageBandits.part1_with_input(input) == 36334
  end

  test "part1 - full round 3" do
    input = """
    #######
    #E..EG#
    #.#G.E#
    #E.##E#
    #G..#.#
    #..E#.#
    #######
    """

    assert BeverageBandits.part1_with_input(input) == 39514
  end

  test "part1 - full round 4" do
    input = """
    #######
    #E.G#.#
    #.#G..#
    #G.#.G#
    #G..#.#
    #...E.#
    #######
    """

    assert BeverageBandits.part1_with_input(input) == 27755
  end

  test "part1 - full round 5" do
    input = """
    #######
    #.E...#
    #.#..G#
    #.###.#
    #E#G#G#
    #...#G#
    #######
    """

    assert BeverageBandits.part1_with_input(input) == 28944
  end

  test "part1 - full round 6" do
    input = """
    #########
    #G......#
    #.E.#...#
    #..##..G#
    #...##..#
    #...#...#
    #.G...G.#
    #.....G.#
    #########
    """

    assert BeverageBandits.part1_with_input(input) == 18740
  end

  test "part2 - full round" do
    input = """
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
    """

    assert BeverageBandits.part2_with_input(input) == 4988
  end

  test "part2 - full round 3" do
    input = """
    #######
    #E..EG#
    #.#G.E#
    #E.##E#
    #G..#.#
    #..E#.#
    #######
    """

    assert BeverageBandits.part2_with_input(input) == 31284
  end

  test "part2 - full round 4" do
    input = """
    #######
    #E.G#.#
    #.#G..#
    #G.#.G#
    #G..#.#
    #...E.#
    #######
    """

    assert BeverageBandits.part2_with_input(input) == 3478
  end

  test "part2 - full round 5" do
    input = """
    #######
    #.E...#
    #.#..G#
    #.###.#
    #E#G#G#
    #...#G#
    #######
    """

    assert BeverageBandits.part2_with_input(input) == 6474
  end

  test "part2 - full round 6" do
    input = """
    #########
    #G......#
    #.E.#...#
    #..##..G#
    #...##..#
    #...#...#
    #.G...G.#
    #.....G.#
    #########
    """

    assert BeverageBandits.part2_with_input(input) == 1140
  end
end
