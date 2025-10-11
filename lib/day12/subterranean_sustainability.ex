defmodule Day12.SubterraneanSustainability do
  def part1() do
    with {:ok, input} <- File.read("priv/day12/input.txt") do
      part1_with_input(input)
    end
  end

  def part2 do
    with {:ok, input} <- File.read("priv/day12/input.txt") do
      part2_with_input(input)
    end
  end

  def part1_with_input(input) do
    {state, rules} = parse(input)

    state
    |> simulate(rules, generations: 20)
    |> score()
  end

  def part2_with_input(input) do
    {state, rules} = parse(input)

    state
    |> simulate(rules, generations: 50_000_000_000)
    |> score()
  end

  defp simulate(state, rules, generations: target) do
    simulate_loop(state, rules, target, _prev_pattern = nil, _generations = 0)
  end

  defp simulate_loop(state, _rules, target, _prev_pattern, generation) when generation == target,
    do: state

  defp simulate_loop(state, rules, target, prev_pattern, generation)
       when not is_nil(prev_pattern) do
    pattern = extract_pattern(state)

    if pattern == prev_pattern do
      remaining = target - generation
      shift_state(state, remaining)
    else
      next_state = evolve(state, rules)
      simulate_loop(next_state, rules, target, pattern, generation + 1)
    end
  end

  defp simulate_loop(state, rules, target, _prev_pattern, generation) do
    pattern = extract_pattern(state)
    next_state = evolve(state, rules)
    simulate_loop(next_state, rules, target, pattern, generation + 1)
  end

  defp evolve(state, rules) do
    {min_pos, max_pos} = find_bounds(state)

    for pos <- (min_pos - 2)..(max_pos + 2), into: %{} do
      neighborhood = get_neighborhood(state, pos)
      next_state = Map.get(rules, neighborhood, :empty)
      {pos, next_state}
    end
  end

  defp get_neighborhood(state, pos) do
    for offset <- -2..2 do
      Map.get(state, pos + offset, :empty)
    end
    |> List.to_tuple()
  end

  defp extract_pattern(state) do
    {min_pos, max_pos} = find_bounds(state)

    min_pos..max_pos
    |> Enum.map(&Map.get(state, &1, :empty))
    |> Enum.map(fn
      :empty -> ?.
      :full -> ?#
    end)
  end

  defp shift_state(state, offset) do
    Map.new(state, fn {pos, pot} -> {pos + offset, pot} end)
  end

  defp find_bounds(state) do
    full_pots =
      state
      |> Enum.filter(fn {_pos, pot} -> pot == :full end)
      |> Enum.map(fn {pos, _pot} -> pos end)

    {Enum.min(full_pots), Enum.max(full_pots)}
  end

  defp score(state) do
    state
    |> Enum.filter(fn {_pos, pot} -> pot == :full end)
    |> Enum.sum_by(fn {pos, _pot} -> pos end)
  end

  defp parse(input) do
    [state_str, guide_str] = String.split(input, "\n\n", trim: true)
    state = parse_state(state_str)
    guide = parse_guide(guide_str)
    {state, guide}
  end

  defp parse_state("initial state: " <> state_str) do
    state_str
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {pot_str, n} -> {n, parse_pot(pot_str)} end)
    |> Enum.into(%{})
  end

  defp parse_guide(guide_str) do
    guide_str
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, &parse_note/2)
  end

  defp parse_note(note_str, guide) do
    [pots_str, next_str] = String.split(note_str, " => ", trim: true)

    pots =
      pots_str
      |> String.graphemes()
      |> Enum.map(&parse_pot/1)
      |> List.to_tuple()

    next = parse_pot(next_str)
    Map.put(guide, pots, next)
  end

  defp parse_pot("."), do: :empty
  defp parse_pot("#"), do: :full
end
