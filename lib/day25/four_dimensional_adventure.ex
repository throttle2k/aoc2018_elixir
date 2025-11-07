defmodule Day25.FourDimensionalAdventure do
  def part1, do: solve(&part1_with_input/1)

  defp solve(solver_fn) do
    File.read!("priv/day25/input.txt")
    |> solver_fn.()
  end

  def part1_with_input(input) do
    input
    |> String.trim()
    |> parse()
    |> to_constellations()
    |> Enum.count()
  end

  defp to_constellations(stars) do
    do_to_constellations(stars, [])
  end

  defp do_to_constellations([], acc), do: acc

  defp do_to_constellations([next | rest], acc) do
    {matches, others} =
      acc
      |> Enum.split_with(fn constellation ->
        Enum.any?(constellation, fn star -> manhattan_distance(star, next) <= 3 end)
      end)

    case length(matches) do
      0 ->
        do_to_constellations(rest, acc ++ [[next]])

      1 ->
        updated_match = Enum.at(matches, 0) ++ [next]
        do_to_constellations(rest, others ++ [updated_match])

      _ ->
        updated_matches = Enum.concat(matches) ++ [next]
        do_to_constellations(rest, others ++ [updated_matches])
    end
  end

  defp manhattan_distance({a1, a2, a3, a4}, {b1, b2, b3, b4}) do
    d1 = abs(a1 - b1)
    d2 = abs(a2 - b2)
    d3 = abs(a3 - b3)
    d4 = abs(a4 - b4)
    d1 + d2 + d3 + d4
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
