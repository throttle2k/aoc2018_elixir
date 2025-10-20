defmodule Day20.ARegularMapTest do
  use ExUnit.Case, async: true
  alias Day20.ARegularMap

  test "part1 - largest number of doors to reach a room 1" do
    input = "^WNE$"

    assert ARegularMap.part1_with_input(input) == 3
  end

  test "part1 - largest number of doors to reach a room 2" do
    input = "^ENWWW(NEEE|SSE(EE|N))$"

    assert ARegularMap.part1_with_input(input) == 10
  end

  test "part1 - largest number of doors to reach a room 3" do
    input = "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$"

    assert ARegularMap.part1_with_input(input) == 18
  end
end
