defmodule Day01.ChronalCalibration do
  def part1() do
    with {:ok, input} <- File.read("priv/day01/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day01/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(:queue.new(), fn n, q -> :queue.in(n, q) end)
    |> do_repeat([], 0)
  end

  def do_repeat(queue, seen, freq) do
    {{:value, val}, new_queue} = :queue.out(queue)
    new_freq = freq + val

    if new_freq in seen do
      new_freq
    else
      do_repeat(:queue.in(val, new_queue), [new_freq | seen], new_freq)
    end
  end
end
