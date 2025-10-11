defmodule Day11.ChronalChargeTest do
  use ExUnit.Case, async: true
  alias Day11.ChronalCharge

  @tag :slow
  test "part1 - max total charge 3x3 with serial 18" do
    assert ChronalCharge.part1(18) == {33, 45}
  end

  @tag :slow
  test "part1 - max total charge 3x3 with serial 42" do
    assert ChronalCharge.part1(42) == {21, 61}
  end

  @tag :slow
  test "part2 - max total charge of any size with serial 18" do
    assert ChronalCharge.part2(18) == {90, 269, 16}
  end

  @tag :slow
  test "part2 - max total charge of any size with serial 42" do
    assert ChronalCharge.part2(42) == {232, 251, 12}
  end
end
