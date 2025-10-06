defmodule Day03.NoMatterHowYouSliceIt do
  def part1() do
    with {:ok, input} <- File.read("priv/day03/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    input
    |> parse()
    |> Enum.count(fn {_k, v} -> length(v) > 1 end)
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day03/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    claims =
      input
      |> parse()

    overlapping =
      claims
      |> Enum.filter(fn {_k, v} -> length(v) > 1 end)
      |> Enum.reduce(MapSet.new(), fn {_k, v}, acc -> MapSet.union(acc, MapSet.new(v)) end)

    claims
    |> Enum.filter(fn {_k, v} -> length(v) == 1 and Enum.at(v, 0) not in overlapping end)
    |> Enum.flat_map(fn {_k, v} -> v end)
    |> Enum.at(0)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, &parse_line/2)
  end

  defp parse_line(line, claims) do
    [id_string, claim_string] = String.split(line, " @ ", trim: true)
    id = parse_id(id_string)

    parse_claims(claim_string)
    |> Enum.reduce(claims, fn claim, claims ->
      Map.update(claims, claim, [id], fn prev -> [id | prev] end)
    end)
  end

  defp parse_id(s) do
    s
    |> String.trim_leading("#")
    |> String.to_integer()
  end

  defp parse_claims(s) do
    [origin, sizes] = String.split(s, ": ", trim: true)

    [col, row] =
      origin
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    [cols, rows] =
      sizes
      |> String.split("x", trim: true)
      |> Enum.map(&String.to_integer/1)

    for delta_row <- 0..(rows - 1), delta_col <- 0..(cols - 1) do
      {row + delta_row, col + delta_col}
    end
  end
end
