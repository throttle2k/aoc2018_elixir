defmodule Day18.SettlersOfTheNorthPoleTest do
  use ExUnit.Case, async: true
  alias Day18.SettlersOfTheNorthPole

  test "part1 - total ersource value of timber after 10 minutes" do
    input = """
    .#.#...|#.
    .....#|##|
    .|..|...#.
    ..|#.....#
    #.#|||#|#|
    ...#.||...
    .|....|...
    ||...#|.#|
    |.||||..|.
    ...#.|..|.
    """

    assert SettlersOfTheNorthPole.part1_with_input(input) == 1147
  end
end
