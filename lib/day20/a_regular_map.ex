defmodule Day20.ARegularMap do
  def part1, do: solve(&part1_with_input/1)
  def part2, do: solve(&part2_with_input/1)

  defp solve(solver_fn) do
    File.read!("priv/day20/input.txt")
    |> String.trim()
    |> solver_fn.()
  end

  def part1_with_input(input) do
    input
    |> walk()
    |> Map.values()
    |> Enum.max()
  end

  def part2_with_input(input) do
    input
    |> walk()
    |> Map.values()
    |> Enum.count(&(&1 >= 1000))
  end

  defp walk(input) do
    input
    |> String.trim_leading("^")
    |> String.trim_trailing("$")
    |> String.graphemes()
    |> do_walk({0, 0}, 0, [], %{{0, 0} => 0})
    |> elem(3)
  end

  defp do_walk([], _pos, _steps, _stack, map), do: {nil, nil, nil, map}

  defp do_walk([dir | rest], pos, steps, stack, map) do
    case dir do
      "(" ->
        do_walk(rest, pos, steps, [{pos, steps} | stack], map)

      "|" ->
        {snapshot_pos, snapshot_steps} = hd(stack)
        do_walk(rest, snapshot_pos, snapshot_steps, stack, map)

      ")" ->
        do_walk(rest, pos, steps, tl(stack), map)

      _ ->
        new_pos = move(dir, pos)
        new_steps = steps + 1
        new_map = Map.update(map, new_pos, new_steps, &min(&1, new_steps))
        do_walk(rest, new_pos, new_steps, stack, new_map)
    end
  end

  defp move("N", {x, y}), do: {x, y - 1}
  defp move("E", {x, y}), do: {x + 1, y}
  defp move("S", {x, y}), do: {x, y + 1}
  defp move("W", {x, y}), do: {x - 1, y}
end
