defmodule Day16.ChronalClassificationTest do
  use ExUnit.Case, async: true
  alias Day16.ChronalClassification
  alias Day16.ChronalClassification.Sample

  test "part1 - samples that behaves like 3 or more opcodes" do
    input = """
    Before: [3, 2, 1, 1]
    9 2 1 2
    After:  [3, 2, 2, 1]



    7 2 0 0
    """

    assert ChronalClassification.part1_with_input(input) == 1
  end
end
