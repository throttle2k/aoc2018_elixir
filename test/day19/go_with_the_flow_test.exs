defmodule Day19.GoWithTheFlowTest do
  use ExUnit.Case, async: true
  alias Day19.GoWithTheFlow

  test "part1 - value of register 0 after program" do
    input = """
    #ip 0
    seti 5 0 1
    seti 6 0 2
    addi 0 1 0
    addr 1 2 3
    setr 1 0 0
    seti 8 0 4
    seti 9 0 5
    """

    assert GoWithTheFlow.part1_with_input(input) == 7
  end
end
