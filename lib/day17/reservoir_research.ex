defmodule Day17.ReservoirResearch do
  defmodule Underground do
    @inf 1_000_000
    @neg_inf -1_000_000

    defstruct [:map, :min_x, :max_x, :min_y, :max_y]

    def new() do
      %__MODULE__{
        map: %{},
        min_x: @inf,
        max_x: @neg_inf,
        min_y: @inf,
        max_y: @neg_inf
      }
    end
  end

  def part1() do
    with {:ok, input} <- File.read("priv/day17/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    parse(input)
    |> run_water({500, 1})
    |> count_all_water()
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day17/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    parse(input)
    |> run_water({500, 1})
    |> count_still_water()
  end

  defp count_all_water(%Underground{} = underground) do
    underground.map
    |> Enum.filter(fn {{_, y}, _} -> y >= underground.min_y end)
    |> Enum.count(fn {_pos, tile} -> tile in [:still_water, :running_water] end)
  end

  defp count_still_water(%Underground{} = underground) do
    underground.map
    |> Enum.filter(fn {{_, y}, _} -> y >= underground.min_y end)
    |> Enum.count(fn {_pos, tile} -> tile == :still_water end)
  end

  defp run_water(underground, {source_x, _} = source) do
    {bottom, updated_underground} = find_bottom(source, underground)

    case bottom do
      :already_full -> updated_underground
      :bottom -> updated_underground
      _ -> fill(updated_underground, {source_x, bottom})
    end
  end

  defp find_bottom({source_x, source_y}, underground) do
    {bottom, updated_underground} =
      source_y..underground.max_y
      |> Enum.reduce_while({source_y, underground}, fn y,
                                                       {_current_bottom, current_underground} ->
        case Map.get(underground.map, {source_x, y}, :dirt) do
          :dirt ->
            updated_map = Map.put(current_underground.map, {source_x, y}, :running_water)
            {:cont, {y, %{current_underground | map: updated_map}}}

          :clay ->
            {:halt, {y - 1, current_underground}}

          :still_water ->
            {:cont, {y, current_underground}}

          :running_water ->
            {:halt, {:already_full, current_underground}}
        end
      end)

    case bottom do
      :already_full -> {:already_full, updated_underground}
      n when n == underground.max_y -> {:bottom, updated_underground}
      n -> {n, updated_underground}
    end
  end

  defp fill(underground, {pos_x, pos_y} = pos) do
    left_border = find_left_border(pos, underground)
    right_border = find_right_border(pos, underground)

    case {left_border, right_border} do
      {{:closed, left}, {:closed, right}} ->
        updated_map =
          for x <- left..right, reduce: underground.map do
            acc -> Map.put(acc, {x, pos_y}, :still_water)
          end

        %{underground | map: updated_map}
        |> fill({pos_x, pos_y - 1})

      {{:closed, left}, {:open, right}} ->
        updated_map =
          for x <- left..(right - 1), reduce: underground.map do
            acc -> Map.put(acc, {x, pos_y}, :running_water)
          end

        %{underground | map: updated_map}
        |> run_water({right, pos_y})

      {{:open, left}, {:closed, right}} ->
        updated_map =
          for x <- (left + 1)..right, reduce: underground.map do
            acc -> Map.put(acc, {x, pos_y}, :running_water)
          end

        %{underground | map: updated_map}
        |> run_water({left, pos_y})

      {{:open, left}, {:open, right}} ->
        updated_map =
          for x <- (left + 1)..(right - 1), reduce: underground.map do
            acc -> Map.put(acc, {x, pos_y}, :running_water)
          end

        %{underground | map: updated_map}
        |> run_water({left, pos_y})
        |> run_water({right, pos_y})

      {:left_border, {:open, right}} ->
        updated_map =
          for x <- underground.min_x..(right - 1), reduce: underground.map do
            acc -> Map.put(acc, {x, pos_y}, :running_water)
          end

        %{underground | map: updated_map, min_x: underground.min_x - 1}
        |> run_water({underground.min_x - 1, pos_y})
        |> run_water({right, pos_y})

      {:left_border, {:closed, right}} ->
        updated_map =
          for x <- underground.min_x..right, reduce: underground.map do
            acc -> Map.put(acc, {x, pos_y}, :running_water)
          end

        %{underground | map: updated_map, min_x: underground.min_x - 1}
        |> run_water({underground.min_x - 1, pos_y})

      {{:open, left}, :right_border} ->
        updated_map =
          for x <- (left + 1)..underground.max_x, reduce: underground.map do
            acc -> Map.put(acc, {x, pos_y}, :running_water)
          end

        %{underground | map: updated_map, max_x: underground.max_x + 1}
        |> run_water({underground.max_x + 1, pos_y})
        |> run_water({left, pos_y})

      {{:closed, left}, :right_border} ->
        updated_map =
          for x <- left..underground.max_x, reduce: underground.map do
            acc -> Map.put(acc, {x, pos_y}, :running_water)
          end

        %{underground | map: updated_map, max_x: underground.max_x + 1}
        |> run_water({underground.max_x + 1, pos_y})
    end
  end

  defp find_left_border({bottom_x, y}, underground) do
    bottom_x..underground.min_x//-1
    |> Enum.reduce_while(:left_border, fn x, current_border ->
      current_area = Map.get(underground.map, {x, y}, :dirt)
      area_below = Map.get(underground.map, {x, y + 1}, :dirt)

      case {current_area, area_below} do
        {:clay, _} -> {:halt, {:closed, x + 1}}
        {_, :dirt} -> {:halt, {:open, x}}
        {_, :running_water} -> {:halt, {:open, x}}
        {_, :clay} -> {:cont, current_border}
        {_, :still_water} -> {:cont, current_border}
        _ -> {:cont, current_border}
      end
    end)
  end

  defp find_right_border({bottom_x, y}, underground) do
    bottom_x..underground.max_x
    |> Enum.reduce_while(:right_border, fn x, current_border ->
      current_area = Map.get(underground.map, {x, y}, :dirt)
      area_below = Map.get(underground.map, {x, y + 1}, :dirt)

      case {current_area, area_below} do
        {:clay, _} -> {:halt, {:closed, x - 1}}
        {_, :dirt} -> {:halt, {:open, x}}
        {_, :running_water} -> {:halt, {:open, x}}
        {_, :clay} -> {:cont, current_border}
        {_, :still_water} -> {:cont, current_border}
        _ -> {:cont, current_border}
      end
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(Underground.new(), &parse_line/2)
  end

  defp parse_line("x=" <> x_and_y_range, underground) do
    [x_str, y_range_str] = String.split(x_and_y_range, ", y=")
    x = String.to_integer(x_str)
    {min_y, max_y} = parse_range(y_range_str)

    for y <- min_y..max_y, reduce: underground do
      acc ->
        new_map = Map.put(acc.map, {x, y}, :clay)
        min_x = min(x, acc.min_x)
        max_x = max(x, acc.max_x)
        min_y = min(y, acc.min_y)
        max_y = max(y, acc.max_y)
        %{acc | map: new_map, min_x: min_x, max_x: max_x, min_y: min_y, max_y: max_y}
    end
  end

  defp parse_line("y=" <> y_and_x_range, underground) do
    [y_str, x_range_str] = String.split(y_and_x_range, ", x=")
    y = String.to_integer(y_str)
    {min_x, max_x} = parse_range(x_range_str)

    for x <- min_x..max_x, reduce: underground do
      acc ->
        new_map = Map.put(acc.map, {x, y}, :clay)
        min_x = min(x, acc.min_x)
        max_x = max(x, acc.max_x)
        min_y = min(y, acc.min_y)
        max_y = max(y, acc.max_y)
        %{acc | map: new_map, min_x: min_x, max_x: max_x, min_y: min_y, max_y: max_y}
    end
  end

  defp parse_range(range) do
    range
    |> String.split("..")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def visualize(%Underground{} = underground) do
    IO.puts("\n")

    for y <- underground.min_y..underground.max_y do
      for x <- underground.max_x..underground.min_x//-1, reduce: [] do
        acc ->
          case Map.get(underground.map, {x, y}, :dirt) do
            :dirt -> ["." | acc]
            :clay -> ["#" | acc]
            :still_water -> ["~" | acc]
            :running_water -> ["|" | acc]
          end
      end
    end
    |> Enum.join("\n")
    |> IO.puts()
  end
end
