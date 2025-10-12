defmodule Day14.ChocolateChartsTest do
  use ExUnit.Case, async: true
  alias Day14.ChocolateCharts

  test "part1 - scores after 9 recipes" do
    assert ChocolateCharts.part1(9) == "5158916779"
  end

  test "part1 - scores after 5 recipes" do
    assert ChocolateCharts.part1(5) == "0124515891"
  end

  test "part1 - scores after 18 recipes" do
    assert ChocolateCharts.part1(18) == "9251071085"
  end

  test "part1 - scores after 2018 recipes" do
    assert ChocolateCharts.part1(2018) == "5941429882"
  end

  test "part2 - 51589 after 9 recipes" do
    assert ChocolateCharts.part2("51589") == 9
  end

  test "part2 - 01245 after 5 recipes" do
    assert ChocolateCharts.part2("01245") == 5
  end

  test "part2 - 92510 after 18 recipes" do
    assert ChocolateCharts.part2("92510") == 18
  end

  test "part2 - 59414 after 2018 recipes" do
    assert ChocolateCharts.part2("59414") == 2018
  end
end
