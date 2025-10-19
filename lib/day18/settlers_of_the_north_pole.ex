defmodule Day18.SettlersOfTheNorthPole do
  defmodule CollectionArea do
    defstruct [:map, :max_row, :max_col]

    def new() do
      %__MODULE__{map: %{}, max_row: 0, max_col: 0}
    end
  end

  def part1() do
    with {:ok, input} <- File.read("priv/day18/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    area =
      input
      |> parse()
      |> tick(10, %{})

    {trees, lumberyards} =
      area.map
      |> Enum.reduce({0, 0}, fn {_k, tile}, {tc, lc} ->
        case tile do
          :tree -> {tc + 1, lc}
          :lumberyard -> {tc, lc + 1}
          _ -> {tc, lc}
        end
      end)

    trees * lumberyards
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day18/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    area =
      input
      |> parse()
      |> tick(1_000_000_000, %{})

    {trees, lumberyards} =
      area.map
      |> Enum.reduce({0, 0}, fn {_k, tile}, {tc, lc} ->
        case tile do
          :tree -> {tc + 1, lc}
          :lumberyard -> {tc, lc + 1}
          _ -> {tc, lc}
        end
      end)

    trees * lumberyards
  end

  defp tick(%CollectionArea{} = area, 0, _), do: area

  defp tick(%CollectionArea{} = area, count, seen) do
    case Map.get(seen, area) do
      nil ->
        updated_map =
          for row <- 0..area.max_row, col <- 0..area.max_col, reduce: area.map do
            current_map ->
              current_tile = Map.fetch!(current_map, {row, col})
              updated_tile = maybe_change({{row, col}, current_tile}, area)
              Map.put(current_map, {row, col}, updated_tile)
          end

        updated_area = %{area | map: updated_map}
        updated_seen = Map.put(seen, area, {count, updated_area})
        tick(updated_area, count - 1, updated_seen)

      {minute, updated_area} ->
        tick(updated_area, rem(count, count - minute) - 1, %{})
    end
  end

  defp maybe_change({pos, :open}, %CollectionArea{} = area) do
    tree_count =
      surroundings(pos, area)
      |> Enum.map(fn surrounding_pos -> Map.fetch!(area.map, surrounding_pos) end)
      |> Enum.count(fn tile -> tile == :tree end)

    if tree_count >= 3, do: :tree, else: :open
  end

  defp maybe_change({pos, :tree}, %CollectionArea{} = area) do
    lumberyard_count =
      surroundings(pos, area)
      |> Enum.map(fn surrounding_pos -> Map.fetch!(area.map, surrounding_pos) end)
      |> Enum.count(fn tile -> tile == :lumberyard end)

    if lumberyard_count >= 3, do: :lumberyard, else: :tree
  end

  defp maybe_change({pos, :lumberyard}, %CollectionArea{} = area) do
    {tree_count, lumberyard_count} =
      surroundings(pos, area)
      |> Enum.map(fn surrounding_pos -> Map.fetch!(area.map, surrounding_pos) end)
      |> Enum.reduce({0, 0}, fn tile, {current_tc, current_lc} ->
        case tile do
          :tree -> {current_tc + 1, current_lc}
          :lumberyard -> {current_tc, current_lc + 1}
          _ -> {current_tc, current_lc}
        end
      end)

    if tree_count >= 1 and lumberyard_count >= 1, do: :lumberyard, else: :open
  end

  defp surroundings({row, col}, %CollectionArea{} = area) do
    for drow <- -1..1, dcol <- -1..1, {drow, dcol} != {0, 0} do
      {drow, dcol}
    end
    |> Enum.reduce([], fn {drow, dcol}, around ->
      case {row + drow, col + dcol} do
        {new_row, new_col} when new_row < 0 or new_col < 0 -> around
        {new_row, new_col} when new_row > area.max_row or new_col > area.max_col -> around
        tile -> [tile | around]
      end
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(CollectionArea.new(), &parse_row/2)
  end

  defp parse_row({line, row}, %CollectionArea{} = area) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(area, fn {char, col}, current_area ->
      new_map = Map.put(current_area.map, {row, col}, parse_tile(char))
      cols = max(col, current_area.max_col)
      rows = max(row, current_area.max_row)
      %{current_area | map: new_map, max_row: rows, max_col: cols}
    end)
  end

  defp parse_tile("."), do: :open
  defp parse_tile("|"), do: :tree
  defp parse_tile("#"), do: :lumberyard
end
