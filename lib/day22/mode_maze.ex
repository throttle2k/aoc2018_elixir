defmodule Day22.ModeMaze do
  @input """
  depth: 8103
  target: 9,758
  """

  def part1(input \\ @input) do
    {depth, target} = parse(input)

    preload_erosion_level_map(depth, target)
    |> determine_risk_level(target)
  end

  defp determine_risk_level(type_map, {tx, ty}) do
    type_map
    |> Enum.reject(fn {{x, y}, _} -> x > tx or y > ty end)
    |> Enum.map(fn {_, el} -> to_type(el) end)
    |> Enum.map(&risk_of/1)
    |> Enum.sum()
  end

  def part2(input \\ @input) do
    {depth, target} = parse(input)

    start = {{0, 0}, :torch}
    queue = :gb_sets.singleton({0, start})
    distances = %{start => 0}

    type_map = preload_erosion_level_map(depth, target)

    dijkstra(type_map, queue, target, MapSet.new(), distances)
    |> Map.get({target, :torch})
  end

  defp dijkstra(type_map, queue, target, visited, distances) do
    if :gb_sets.is_empty(queue) do
      distances
    else
      {{dist, {pos, tool}}, rest} = :gb_sets.take_smallest(queue)

      if {pos, tool} == {target, :torch} do
        distances
      else
        if MapSet.member?(visited, {pos, tool}) do
          dijkstra(type_map, rest, target, visited, distances)
        else
          updated_visited = MapSet.put(visited, {pos, tool})

          neighbors_list = get_neighbors(pos, tool, type_map)

          {updated_queue, updated_distances} =
            neighbors_list
            |> Enum.reject(fn {n_pos, n_tool, _} ->
              MapSet.member?(updated_visited, {n_pos, n_tool})
            end)
            |> Enum.reduce({rest, distances}, fn {n_pos, n_tool, n_w},
                                                 {current_queue, current_distances} ->
              neighbor_total_dist = dist + n_w
              current_dist = Map.get(current_distances, {n_pos, n_tool}, :infinity)

              if neighbor_total_dist < current_dist do
                updated_distances =
                  Map.put(current_distances, {n_pos, n_tool}, neighbor_total_dist)

                updated_queue =
                  :gb_sets.add_element({neighbor_total_dist, {n_pos, n_tool}}, current_queue)

                {updated_queue, updated_distances}
              else
                {current_queue, current_distances}
              end
            end)

          dijkstra(type_map, updated_queue, target, updated_visited, updated_distances)
        end
      end
    end
  end

  defp get_neighbors({x, y} = pos, tool, type_map) do
    current_type = Map.get(type_map, pos) |> to_type()

    candidates =
      [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
      |> Enum.filter(fn {nx, ny} -> nx >= 0 and ny >= 0 end)

    move_neighbors =
      candidates
      |> Enum.filter(fn neighbor -> Map.has_key?(type_map, neighbor) end)
      |> Enum.filter(fn neighbor ->
        neighbor_type = Map.get(type_map, neighbor) |> to_type()
        tool_valid_for_cell?(tool, neighbor_type)
      end)
      |> Enum.map(fn neighbor -> {neighbor, tool, 1} end)

    tool_changes =
      valid_tools_for_cell(current_type)
      |> Enum.filter(fn t -> t != tool end)
      |> Enum.map(fn new_tool -> {{x, y}, new_tool, 7} end)

    move_neighbors ++ tool_changes
  end

  defp tool_valid_for_cell?(tool, cell_type) do
    case cell_type do
      :rocky -> tool in [:torch, :climbing_gear]
      :wet -> tool in [:climbing_gear, :neither]
      :narrow -> tool in [:torch, :neither]
    end
  end

  defp valid_tools_for_cell(cell_type) do
    case cell_type do
      :rocky -> [:torch, :climbing_gear]
      :wet -> [:climbing_gear, :neither]
      :narrow -> [:torch, :neither]
    end
  end

  defp to_type(erosion_level) when rem(erosion_level, 3) == 0, do: :rocky
  defp to_type(erosion_level) when rem(erosion_level, 3) == 1, do: :wet
  defp to_type(erosion_level) when rem(erosion_level, 3) == 2, do: :narrow

  defp risk_of(:rocky), do: 0
  defp risk_of(:wet), do: 1
  defp risk_of(:narrow), do: 2

  defp preload_erosion_level_map(depth, {tx, ty} = target) do
    max_x = tx + div(tx, 2) + 50
    max_y = ty + div(ty, 2) + 50

    for y <- 0..max_y, x <- 0..max_x, reduce: %{} do
      erosion_level ->
        el =
          case {x, y} do
            {0, 0} ->
              rem(depth, 20183)

            ^target ->
              rem(depth, 20183)

            {x, 0} ->
              rem(x * 16807 + depth, 20183)

            {0, y} ->
              rem(y * 48271 + depth, 20183)

            {x, y} ->
              erosion_left = Map.fetch!(erosion_level, {x - 1, y})
              erosion_above = Map.fetch!(erosion_level, {x, y - 1})
              geo_index = erosion_left * erosion_above
              rem(geo_index + depth, 20183)
          end

        Map.put(erosion_level, {x, y}, el)
    end
  end

  defp parse(input) do
    [depth_str, target_str] =
      input
      |> String.trim()
      |> String.split("\n")

    {parse_depth(depth_str), parse_target(target_str)}
  end

  defp parse_depth("depth: " <> depth_str) do
    String.to_integer(depth_str)
  end

  defp parse_target("target: " <> target_str) do
    target_str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end
