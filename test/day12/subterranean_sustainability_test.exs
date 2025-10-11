defmodule Day12.SubterraneanSustainabilityTest do
  use ExUnit.Case, async: true
  alias Day12.SubterraneanSustainability

  @input """
  initial state: #..#.#..##......###...###

  ...## => #
  ..#.. => #
  .#... => #
  .#.#. => #
  .#.## => #
  .##.. => #
  .#### => #
  #.#.# => #
  #.### => #
  ##.#. => #
  ##.## => #
  ###.. => #
  ###.# => #
  ####. => #
  """

  test "part1 - sum at 20th generation" do
    assert SubterraneanSustainability.part1_with_input(@input) == 325
  end
end
