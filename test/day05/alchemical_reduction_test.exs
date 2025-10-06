defmodule Day05.AlchemicalReductionTest do
  use ExUnit.Case, async: true
  alias Day05.AlchemicalReduction

  test "part1 - polymers after full reaction" do
    input = "dabAcCaCBAcCcaDA"

    assert AlchemicalReduction.part1_with_input(input) == 10
  end

  test "part2 - shortest polymer after removing unit" do
    input = "dabAcCaCBAcCcaDA"

    assert AlchemicalReduction.part2_with_input(input) == 4
  end
end
