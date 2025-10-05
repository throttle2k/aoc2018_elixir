defmodule Day01.ChronalCalibrationTest do
  use ExUnit.Case, async: true
  alias Day01.ChronalCalibration

  test "part1 - resulting frequency" do
    input = """
    +1
    -2
    +3
    +1
    """

    assert ChronalCalibration.part1_with_input(input) == 3
  end

  test "part2 - first repeating frequency" do
    input = """
    +1
    -2
    +3
    +1
    """

    assert ChronalCalibration.part2_with_input(input) == 2
  end
end
