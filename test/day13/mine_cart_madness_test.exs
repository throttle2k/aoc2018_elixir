defmodule Day13.MineCartMadnessTest do
  use ExUnit.Case, async: true
  alias Day13.MineCartMadness

  @input1 """
  /->-\\        
  |   |  /----\\
  | /-+--+-\\  |
  | | |  | v  |
  \\-+-/  \\-+--/
    \\------/
  """

  test "part1 - find first crash position" do
    assert MineCartMadness.part1_with_input(@input1) == "7,3"
  end

  @input2 """
  />-<\\  
  |   |  
  | /<+-\\
  | | | v
  \\>+</ |
    |   ^
    \\<->/
  """

  test "part2 - find last cart position" do
    assert MineCartMadness.part2_with_input(@input2) == "6,4"
  end
end
