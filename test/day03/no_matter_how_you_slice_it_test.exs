defmodule Day03.NoMatterHowYouSliceItTest do
  use ExUnit.Case, async: true
  alias Day03.NoMatterHowYouSliceIt

  test "part1 - count square inch of fabric" do
    input = """
    #1 @ 1,3: 4x4
    #2 @ 3,1: 4x4
    #3 @ 5,5: 2x2
    """

    assert NoMatterHowYouSliceIt.part1_with_input(input) == 4
  end

  test "part2 - the only claim that does not overlap" do
    input = """
    #1 @ 1,3: 4x4
    #2 @ 3,1: 4x4
    #3 @ 5,5: 2x2
    """

    assert NoMatterHowYouSliceIt.part2_with_input(input) == 3
  end
end
