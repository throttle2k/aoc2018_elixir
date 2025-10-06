defmodule Day02.InventoryManagementSystemTest do
  use ExUnit.Case, async: true
  alias Day02.InventoryManagementSystem

  test "part1 - checksum for list of box ids" do
    input = """
    abcdef
    bababc
    abbcde
    abcccd
    aabcdd
    abcdee
    ababab
    """

    assert InventoryManagementSystem.part1_with_input(input) == 12
  end

  test "part2 - letters common between corrext boxes ids" do
    input = """
    abcde
    fghij
    klmno
    pqrst
    fguij
    axcye
    wvxyz
    """

    assert InventoryManagementSystem.part2_with_input(input) == "fgij"
  end
end
