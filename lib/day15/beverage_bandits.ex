defmodule Day15.BeverageBandits do
  def part1() do
    with {:ok, input} <- File.read("priv/day15/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    parse(input)
    |> run()
    |> elem(1)
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day15/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    initial_state = parse(input)

    original_elves_count = count_elves(initial_state)

    Stream.iterate(4, &(&1 + 1))
    |> Enum.reduce_while(0, fn elf_attack_power, _ ->
      outcome = run(initial_state, elf_attack_power: elf_attack_power)

      if count_elves(elem(outcome, 0)) == original_elves_count do
        {:halt, elem(outcome, 1)}
      else
        {:cont, 0}
      end
    end)
  end

  defp count_elves(state) do
    Enum.count(state, fn
      {_, {entity, _}} -> entity == :elf
      {_, _} -> nil
    end)
  end

  def run(state, opts \\ []) do
    debug = Keyword.get(opts, :debug, false)
    elf_attack_power = Keyword.get(opts, :elf_attack_power, 3)

    do_run(state, 0, debug, elf_attack_power)
  end

  defp do_run(state, round, debug, elf_attack_power) do
    if debug do
      IO.puts("\n=== Round: #{round} ===")
      IO.puts(visualize(state))
    end

    case get_winner(state) do
      :none ->
        case next_round_with_early_termination(state, debug, elf_attack_power) do
          {:complete, new_state} ->
            do_run(new_state, round + 1, debug, elf_attack_power)

          {:terminated, new_state} ->
            entity = get_winner(new_state)
            outcome = sum_hp(new_state, entity) * round

            if debug do
              IO.puts("\n=== Combat ends during round #{round + 1} (#{round} full rounds) ===")
              IO.puts(visualize(new_state))
              IO.puts("Outcome: #{sum_hp(new_state, entity)} * #{round} = #{outcome}")
            end

            {new_state, outcome}
        end

      entity ->
        outcome = sum_hp(state, entity) * round

        if debug do
          IO.puts("\n=== Combat ends after #{round} full rounds ===")
          IO.puts(visualize(state))
          IO.puts("Outcome: #{sum_hp(state, entity)} * #{round} = #{outcome}")
        end

        {state, outcome}
    end
  end

  defp next_round_with_early_termination(state, debug, elf_attack_power) do
    entities = get_all_entities_sorted(state)

    result =
      Enum.reduce_while(entities, state, fn {pos, entity_type}, curr_state ->
        case Map.get(curr_state, pos) do
          {^entity_type, _hp} ->
            enemy_type = opposite_entity(entity_type)

            if has_any_enemy?(curr_state, enemy_type) do
              if debug do
                IO.puts("\n#{entity_type} at #{inspect(pos)}:")
              end

              {after_move_state, new_pos} = try_move(curr_state, pos, entity_type, debug)

              if debug and new_pos != pos do
                IO.puts("  Moved to #{inspect(new_pos)}")
              end

              attack_power =
                case entity_type do
                  :elf -> elf_attack_power
                  :goblin -> 3
                end

              after_attack_state = try_attack(after_move_state, new_pos, debug, attack_power)

              {:cont, after_attack_state}
            else
              if debug do
                IO.puts("\n#{entity_type} at #{inspect(pos)} finds no targets, combat ends")
              end

              {:halt, {:terminated, curr_state}}
            end

          _ ->
            if debug do
              IO.puts("\n#{entity_type} at #{inspect(pos)} is already dead, skipping")
            end

            {:cont, curr_state}
        end
      end)

    case result do
      {:terminated, final_state} -> {:terminated, final_state}
      final_state -> {:complete, final_state}
    end
  end

  defp get_all_entities_sorted(state) do
    state
    |> Enum.filter(fn
      {_pos, {:goblin, _}} -> true
      {_pos, {:elf, _}} -> true
      _ -> false
    end)
    |> Enum.map(fn {pos, {type, _}} -> {pos, type} end)
    |> Enum.sort_by(fn {{row, col}, _} -> {row, col} end)
  end

  defp try_move(state, pos, entity_type, debug) do
    enemy_type = opposite_entity(entity_type)

    if has_adjacent_enemy?(state, pos, enemy_type) do
      if debug, do: IO.puts("  Already adjacent to enemy, not moving")
      {state, pos}
    else
      case find_move_target(state, pos, enemy_type, debug) do
        nil ->
          if debug, do: IO.puts("  No reachable targets")
          {state, pos}

        next_pos ->
          entity_data = Map.fetch!(state, pos)

          new_state =
            state
            |> Map.put(pos, :tile)
            |> Map.put(next_pos, entity_data)

          {new_state, next_pos}
      end
    end
  end

  defp try_attack(state, pos, debug, attack_power) do
    case find_attack_target(state, pos) do
      nil ->
        if debug, do: IO.puts("  No target to attack")
        state

      target_pos ->
        {_, hp} = Map.fetch!(state, target_pos)
        if debug, do: IO.puts("  Attacking #{inspect(target_pos)} (HP: #{hp})")
        resolve_attack(state, target_pos, attack_power)
    end
  end

  defp find_move_target(state, from_pos, enemy_type, debug) do
    targets = find_in_range_positions(state, enemy_type)

    if debug and not Enum.empty?(targets) do
      IO.puts(
        "  Targets in range: #{inspect(Enum.take(targets, 5))}#{if length(targets) > 5, do: "...", else: ""}"
      )
    end

    if Enum.empty?(targets) do
      nil
    else
      reachable_targets =
        targets
        |> Enum.map(fn target ->
          case find_shortest_path(state, from_pos, target) do
            {:ok, path} -> {target, path}
            :no_path -> nil
          end
        end)
        |> Enum.reject(&is_nil/1)

      if Enum.empty?(reachable_targets) do
        nil
      else
        min_distance =
          reachable_targets
          |> Enum.map(fn {_, path} -> length(path) end)
          |> Enum.min()

        closest_targets =
          reachable_targets
          |> Enum.filter(fn {_, path} -> length(path) == min_distance end)

        {chosen_target, _} =
          closest_targets
          |> Enum.min_by(fn {{r, c}, _path} -> {r, c} end)

        if debug do
          IO.puts("  Chosen target: #{inspect(chosen_target)} (distance: #{min_distance})")
        end

        possible_first_steps =
          get_adjacent_empty(state, from_pos)
          |> Enum.map(fn first_step ->
            case find_shortest_path(state, first_step, chosen_target) do
              {:ok, path} -> {first_step, length(path) + 1}
              :no_path -> nil
            end
          end)
          |> Enum.reject(&is_nil/1)

        if Enum.empty?(possible_first_steps) do
          nil
        else
          min_step_distance =
            possible_first_steps
            |> Enum.map(fn {_, dist} -> dist end)
            |> Enum.min()

          {chosen_step, _} =
            possible_first_steps
            |> Enum.filter(fn {_, dist} -> dist == min_step_distance end)
            |> Enum.min_by(fn {{r, c}, _} -> {r, c} end)

          if debug do
            IO.puts("  Chosen step: #{inspect(chosen_step)}")
          end

          chosen_step
        end
      end
    end
  end

  defp find_in_range_positions(state, enemy_type) do
    state
    |> Enum.filter(fn {_pos, val} ->
      match?({^enemy_type, _}, val)
    end)
    |> Enum.flat_map(fn {pos, _} ->
      get_adjacent_empty(state, pos)
    end)
    |> Enum.uniq()
    |> Enum.sort_by(fn {r, c} -> {r, c} end)
  end

  defp find_attack_target(state, pos) do
    entity_data = Map.fetch!(state, pos)

    enemy_type =
      case entity_data do
        {:goblin, _} -> :elf
        {:elf, _} -> :goblin
      end

    get_adjacent_positions(pos)
    |> Enum.filter(fn adj_pos ->
      case Map.get(state, adj_pos) do
        {^enemy_type, _hp} -> true
        _ -> false
      end
    end)
    |> case do
      [] ->
        nil

      enemies ->
        Enum.min_by(enemies, fn enemy_pos ->
          {_, hp} = Map.fetch!(state, enemy_pos)
          {row, col} = enemy_pos
          {hp, row, col}
        end)
    end
  end

  defp resolve_attack(state, target_pos, attack_power) do
    {entity, hp} = Map.fetch!(state, target_pos)

    case hp - attack_power do
      n when n <= 0 -> Map.put(state, target_pos, :tile)
      n -> Map.put(state, target_pos, {entity, n})
    end
  end

  defp find_shortest_path(state, from, to) do
    if from == to do
      {:ok, []}
    else
      do_find_shortest_path(
        state,
        to,
        [{from, manhattan_distance(from, to)}],
        %{from => 0},
        %{from => nil}
      )
    end
  end

  defp do_find_shortest_path(_state, _target, [], _distances, _parents) do
    :no_path
  end

  defp do_find_shortest_path(_state, target, [{target, _weight} | _], _distances, parents) do
    path = reconstruct_path(target, parents)
    {:ok, path}
  end

  defp do_find_shortest_path(state, target, [{current_pos, _weight} | rest], distances, parents) do
    {new_distances, new_parents, new_candidates} =
      get_adjacent_empty(state, current_pos)
      |> Enum.reduce({distances, parents, rest}, fn neighbor, {dists, pars, cands} ->
        proposed_distance = distances[current_pos] + 1

        if not Map.has_key?(dists, neighbor) or dists[neighbor] > proposed_distance do
          new_dists = Map.put(dists, neighbor, proposed_distance)
          new_pars = Map.put(pars, neighbor, current_pos)
          priority = proposed_distance + manhattan_distance(neighbor, target)

          new_cands = insert_sorted(cands, {neighbor, priority})

          {new_dists, new_pars, new_cands}
        else
          {dists, pars, cands}
        end
      end)

    do_find_shortest_path(state, target, new_candidates, new_distances, new_parents)
  end

  defp insert_sorted(list, {pos, priority}) do
    Enum.sort_by([{pos, priority} | list], fn {{r, c}, p} -> {p, r, c} end)
  end

  defp reconstruct_path(target, parents) do
    do_reconstruct_path(target, parents, [])
  end

  defp do_reconstruct_path(current, parents, path) do
    case parents[current] do
      nil -> path
      parent -> do_reconstruct_path(parent, parents, [current | path])
    end
  end

  defp has_any_enemy?(state, enemy_type) do
    Enum.any?(state, fn {_, v} -> match?({^enemy_type, _}, v) end)
  end

  defp opposite_entity(:goblin), do: :elf
  defp opposite_entity(:elf), do: :goblin

  defp has_adjacent_enemy?(state, pos, enemy_type) do
    get_adjacent_positions(pos)
    |> Enum.any?(fn adj_pos ->
      match?({^enemy_type, _}, Map.get(state, adj_pos))
    end)
  end

  defp get_adjacent_positions({row, col}) do
    [{row - 1, col}, {row, col - 1}, {row, col + 1}, {row + 1, col}]
  end

  defp get_adjacent_empty(state, pos) do
    get_adjacent_positions(pos)
    |> Enum.filter(fn adj_pos ->
      Map.get(state, adj_pos) == :tile
    end)
  end

  defp manhattan_distance({r1, c1}, {r2, c2}) do
    abs(r2 - r1) + abs(c2 - c1)
  end

  defp get_winner(state) do
    has_goblins = Enum.any?(state, fn {_, v} -> match?({:goblin, _}, v) end)
    has_elves = Enum.any?(state, fn {_, v} -> match?({:elf, _}, v) end)

    cond do
      not has_goblins -> :elf
      not has_elves -> :goblin
      true -> :none
    end
  end

  defp sum_hp(state, entity) do
    state
    |> Enum.filter(fn {_, v} -> match?({^entity, _}, v) end)
    |> Enum.map(fn {_, {_, hp}} -> hp end)
    |> Enum.sum()
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, &parse_line/2)
  end

  defp parse_line({line, row}, state) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(state, fn {c, col}, current_state ->
      parse_cell(c, row, col, current_state)
    end)
  end

  defp parse_cell(c, row, col, state) do
    case c do
      "#" -> Map.put(state, {row, col}, :wall)
      "." -> Map.put(state, {row, col}, :tile)
      "G" -> Map.put(state, {row, col}, {:goblin, 200})
      "E" -> Map.put(state, {row, col}, {:elf, 200})
    end
  end

  def visualize(state) do
    max_row = state |> Enum.map(fn {{row, _}, _} -> row end) |> Enum.max()
    max_col = state |> Enum.map(fn {{_, col}, _} -> col end) |> Enum.max()

    for row <- 0..max_row do
      line =
        for col <- 0..max_col do
          cell = Map.fetch!(state, {row, col})
          cell_to_string(cell)
        end
        |> Enum.join()

      entities_in_row =
        for col <- 0..max_col do
          case Map.fetch!(state, {row, col}) do
            {type, hp} -> "#{type_char(type)}(#{hp})"
            _ -> nil
          end
        end
        |> Enum.reject(&is_nil/1)

      if Enum.empty?(entities_in_row) do
        line
      else
        line <> "   " <> Enum.join(entities_in_row, ", ")
      end
    end
    |> Enum.join("\n")
  end

  defp cell_to_string(:wall), do: "#"
  defp cell_to_string(:tile), do: "."
  defp cell_to_string({:goblin, _}), do: "G"
  defp cell_to_string({:elf, _}), do: "E"

  defp type_char(:goblin), do: "G"
  defp type_char(:elf), do: "E"
end
