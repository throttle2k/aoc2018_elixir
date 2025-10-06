defmodule Day05.AlchemicalReduction do
  @upcase_downcase_diff 32

  def part1() do
    with {:ok, input} <- File.read("priv/day05/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    input
    |> String.to_charlist()
    |> react_charlist()
    |> length()
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day05/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    polymer =
      input
      |> String.trim()
      |> String.to_charlist()

    units = get_unique_units(polymer)

    units
    |> Task.async_stream(fn unit_char ->
      polymer
      |> remove_unit(unit_char)
      |> react_charlist()
      |> length
    end)
    |> Enum.map(fn {:ok, len} -> len end)
    |> Enum.min()
  end

  defp get_unique_units(charlist) do
    charlist
    |> Enum.map(&to_lowercase_char/1)
    |> Enum.uniq()
  end

  defp remove_unit(charlist, unit_char) do
    upper_char = unit_char - @upcase_downcase_diff

    Enum.reject(charlist, fn c -> c == unit_char or c == upper_char end)
  end

  defp react_charlist(polymer) do
    polymer
    |> Enum.reduce([], fn char, stack ->
      case stack do
        [top | rest] when abs(char - top) == @upcase_downcase_diff -> rest
        _ -> [char | stack]
      end
    end)
  end

  defp to_lowercase_char(char) when char >= ?A and char <= ?Z do
    char + @upcase_downcase_diff
  end

  defp to_lowercase_char(char), do: char
end
