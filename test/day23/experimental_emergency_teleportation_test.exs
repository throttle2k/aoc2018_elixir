defmodule Day23.ExperimentalEmergencyTeleportationTest do
  use ExUnit.Case, async: true
  alias Day23.ExperimentalEmergencyTeleportation

  test "part1 - nanobots in range" do
    input = """
    pos=<0,0,0>, r=4
    pos=<1,0,0>, r=1
    pos=<4,0,0>, r=3
    pos=<0,2,0>, r=1
    pos=<0,5,0>, r=3
    pos=<0,0,3>, r=1
    pos=<1,1,1>, r=1
    pos=<1,1,2>, r=1
    pos=<1,3,1>, r=1
    """

    assert ExperimentalEmergencyTeleportation.part1_with_input(input) == 7
  end

  test "part2 - manhattan distance to point in range of largest numbers of nanobots" do
    input = """
    pos=<10,12,12>, r=2
    pos=<12,14,12>, r=2
    pos=<16,12,12>, r=4
    pos=<14,14,14>, r=6
    pos=<50,50,50>, r=200
    pos=<10,10,10>, r=5
    """

    assert ExperimentalEmergencyTeleportation.part2_with_input(input) == 36
  end
end
