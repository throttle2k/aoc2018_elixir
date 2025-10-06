defmodule Day06.ChronalCoordinates do
  def part1() do
    with {:ok, input} <- File.read("priv/day06/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    coordinates = parse(input)
    bounds = find_bounds(coordinates)

    coordinates
    |> build_areas(bounds)
    |> reject_infinite_areas(bounds)
    |> Enum.map(fn {_coord, points} -> length(points) end)
    |> Enum.max()
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day06/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input, max_distance \\ 10000) do
    coordinates = parse(input)
    bounds = find_bounds(coordinates)

    count_safe_regions(coordinates, bounds, max_distance)
  end

  defp count_safe_regions(coordinates, bounds, max_distance) do
    for row <- bounds.min_row..bounds.max_row,
        col <- bounds.min_col..bounds.max_col,
        total_distance(coordinates, {row, col}) < max_distance do
      true
    end
    |> length()
  end

  defp total_distance(coordinates, point) do
    Enum.reduce(coordinates, 0, fn coord, acc ->
      acc + manhattan_distance(point, coord)
    end)
  end

  defp build_areas(coordinates, bounds) do
    for row <- bounds.min_row..bounds.max_row,
        col <- bounds.min_col..bounds.max_col,
        reduce: %{} do
      areas ->
        point = {row, col}

        case find_closest_coordinate(coordinates, point) do
          {:ok, closest} -> Map.update(areas, closest, [point], &[point | &1])
          :tie -> areas
        end
    end
  end

  defp find_closest_coordinate(coordinates, point) do
    distances =
      Enum.map(coordinates, fn coord ->
        {coord, manhattan_distance(point, coord)}
      end)

    min_distance = distances |> Enum.map(&elem(&1, 1)) |> Enum.min()

    case Enum.filter(distances, fn {_coord, dist} -> dist == min_distance end) do
      [{closest, _}] -> {:ok, closest}
      _ -> :tie
    end
  end

  defp reject_infinite_areas(areas, bounds) do
    Enum.reject(areas, fn {_coord, points} ->
      Enum.any?(points, &touches_boundary?(&1, bounds))
    end)
  end

  defp touches_boundary?({row, col}, bounds) do
    row == bounds.min_row or row == bounds.max_row or
      col == bounds.min_col or col == bounds.max_col
  end

  defp manhattan_distance({row1, col1}, {row2, col2}) do
    abs(row2 - row1) + abs(col2 - col1)
  end

  defp find_bounds(coordinates) do
    {min_row, max_row} = coordinates |> Enum.map(&elem(&1, 0)) |> Enum.min_max()
    {min_col, max_col} = coordinates |> Enum.map(&elem(&1, 1)) |> Enum.min_max()
    %{min_row: min_row, min_col: min_col, max_row: max_row, max_col: max_col}
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [col, row] =
      line
      |> String.split(", ", trim: true)
      |> Enum.map(&String.to_integer/1)

    {row, col}
  end
end
