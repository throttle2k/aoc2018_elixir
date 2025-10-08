defmodule Day09.MarbleManiaTest do
  use ExUnit.Case, async: true
  alias Day09.MarbleMania

  test "part1 - highest score 9 players last marble 25" do
    assert MarbleMania.part1(9, 25) == 32
  end

  test "part1 - highest score 10 players last marble 1618" do
    assert MarbleMania.part1(10, 1618) == 8317
  end

  test "part1 - highest score 13 players last marble 7999" do
    assert MarbleMania.part1(13, 7999) == 146_373
  end

  test "part1 - highest score 17 players last marble 1104" do
    assert MarbleMania.part1(17, 1104) == 2764
  end

  test "part1 - highest score 21 players last marble 6111" do
    assert MarbleMania.part1(21, 6111) == 54718
  end

  test "part1 - highest score 30 players last marble 5807" do
    assert MarbleMania.part1(30, 5807) == 37305
  end
end
