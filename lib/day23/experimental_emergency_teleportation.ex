defmodule Day23.ExperimentalEmergencyTeleportation do
  def part1(), do: solve(&part1_with_input/1)
  def part2(), do: solve(&part2_with_input/1)

  defp solve(solver_fn) do
    File.read!("priv/day23/input.txt")
    |> solver_fn.()
  end

  def part1_with_input(input) do
    nanobots =
      input
      |> String.trim()
      |> parse()

    Enum.max_by(nanobots, fn {_pos, radius} -> radius end)
    |> find_nanobots_in_range(nanobots)
    |> length()
  end

  def part2_with_input(input) do
    nanobots =
      input
      |> String.trim()
      |> parse()
      |> Map.to_list()

    bounds = compute_bounds(nanobots)

    best_pos = iterative_search(bounds, nanobots)

    manhattan_distance(best_pos, {0, 0, 0})
  end

  defp compute_bounds(nanobots) do
    nanobots
    |> Enum.reduce(
      {nil, nil, nil, nil, nil, nil},
      fn {{x, y, z}, _r}, {min_x, min_y, min_z, max_x, max_y, max_z} ->
        {
          min(min_x || x, x),
          min(min_y || y, y),
          min(min_z || z, z),
          max(max_x || x, x),
          max(max_y || y, y),
          max(max_z || z, z)
        }
      end
    )
    |> then(fn {min_x, min_y, min_z, max_x, max_y, max_z} ->
      {{min_x, min_y, min_z}, {max_x, max_y, max_z}}
    end)
  end

  defp iterative_search(initial_bounds, nanobots) do
    do_iterative_search(initial_bounds, nanobots, 1_000_000)
  end

  defp do_iterative_search(
         {{min_x, min_y, min_z}, {max_x, max_y, max_z}} = bounds,
         nanobots,
         step
       ) do
    size = max(max_x - min_x, max(max_y - min_y, max_z - min_z))

    if size <= 10 or step == 0 do
      brute_force_search(bounds, nanobots) |> elem(0)
    else
      current_step = max(div(size, 10), 1)

      candidates =
        for x <- min_x..max_x//current_step,
            y <- min_y..max_y//current_step,
            z <- min_z..max_z//current_step do
          pos = {x, y, z}
          count = count_in_range(pos, nanobots)
          dist = manhattan_distance(pos, {0, 0, 0})
          {pos, count, dist}
        end

      {best_pos, _best_count, _best_dist} =
        candidates
        |> Enum.max_by(fn {_pos, count, dist} -> {count, -dist} end)

      {bx, by, bz} = best_pos
      margin = current_step * 2

      new_bounds = {
        {max(min_x, bx - margin), max(min_y, by - margin), max(min_z, bz - margin)},
        {min(max_x, bx + margin), min(max_y, by + margin), min(max_z, bz + margin)}
      }

      do_iterative_search(new_bounds, nanobots, div(current_step, 2))
    end
  end

  defp brute_force_search({{min_x, min_y, min_z}, {max_x, max_y, max_z}}, nanobots) do
    for x <- min_x..max_x,
        y <- min_y..max_y,
        z <- min_z..max_z,
        reduce: {{min_x, min_y, min_z}, 0} do
      {best_pos, best_count} ->
        count = count_in_range({x, y, z}, nanobots)
        dist = manhattan_distance({x, y, z}, {0, 0, 0})
        best_dist = manhattan_distance(best_pos, {0, 0, 0})

        cond do
          count > best_count -> {{x, y, z}, count}
          count == best_count and dist < best_dist -> {{x, y, z}, count}
          true -> {best_pos, best_count}
        end
    end
  end

  defp find_nanobots_in_range({strongest_pos, radius}, nanobots) do
    nanobots
    |> Enum.filter(fn {pos, _r} ->
      manhattan_distance(strongest_pos, pos) <= radius
    end)
  end

  defp count_in_range(pos, nanobots) do
    Enum.count(nanobots, fn {bot_pos, radius} ->
      manhattan_distance(bot_pos, pos) <= radius
    end)
  end

  defp manhattan_distance({x, y, z}, {sx, sy, sz}) do
    abs(sx - x) + abs(sy - y) + abs(sz - z)
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.reduce(%{}, &parse_line/2)
  end

  defp parse_line(line, nanobots) do
    [pos_str, radius_str] = String.split(line, ", ")
    Map.put(nanobots, parse_pos(pos_str), parse_radius(radius_str))
  end

  defp parse_pos("pos=" <> pos_str) do
    pos_str
    |> String.trim_leading("<")
    |> String.trim_trailing(">")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp parse_radius("r=" <> radius_str) do
    String.to_integer(radius_str)
  end
end
