defmodule Day24.ImmuneSystemSimulator20xx do
  def part1(), do: solve(&part1_with_input/1)
  def part2(), do: solve(&part2_with_input/1)

  defp solve(solver_fn) do
    File.read!("priv/day24/input.txt")
    |> solver_fn.()
  end

  def part1_with_input(input) do
    input
    |> String.trim()
    |> parse()
    |> process_turns()
    |> elem(1)
    |> Enum.map(fn %{units: units} -> units end)
    |> Enum.sum()
  end

  def part2_with_input(input) do
    armies = input |> String.trim() |> parse()

    Stream.iterate(1, &(&1 + 1))
    |> Enum.find_value(fn boost ->
      result =
        armies
        |> apply_boost(boost)
        |> process_turns()

      case result do
        {:immune_system, armies} -> Enum.map(armies, & &1.units) |> Enum.sum()
        _ -> nil
      end
    end)
  end

  defp apply_boost(armies, boost) do
    Enum.map(armies, fn
      %{id: {:immune_system, _}} = army ->
        %{army | attack: army.attack + boost}

      army ->
        army
    end)
  end

  defp process_turns(armies) do
    Stream.cycle([true])
    |> Enum.reduce_while(armies, fn _, remaining_armies ->
      case check_winner(remaining_armies) do
        :none ->
          selected_targets = process_selection_phase(remaining_armies)
          new_armies = process_attack_phase(remaining_armies, selected_targets)

          if new_armies == remaining_armies do
            {:halt, {:infection, [%{id: {:infection, 0}, units: 1}]}}
          else
            {:cont, process_attack_phase(remaining_armies, selected_targets)}
          end

        winner ->
          {:halt, {winner, remaining_armies}}
      end
    end)
  end

  defp check_winner(armies) do
    freq =
      armies
      |> Enum.map(fn %{id: {s, _}} -> s end)
      |> Enum.frequencies()

    cond do
      not Map.has_key?(freq, :infection) -> :immune_system
      not Map.has_key?(freq, :immune_system) -> :infection
      true -> :none
    end
  end

  defp process_attack_phase(armies, selected_targets) do
    selected_targets
    |> sort_attacks(armies)
    |> Enum.reduce(armies, fn {attacker_id, defender_id}, remaining_armies ->
      attacker = Enum.find(remaining_armies, fn %{id: id} -> id == attacker_id end)
      defender = Enum.find(remaining_armies, fn %{id: id} -> id == defender_id end)

      if attacker != nil and defender != nil do
        damage = calculate_damage(attacker, defender)
        remaining_units = resolve_attack(damage, defender)

        if remaining_units == 0 do
          Enum.reject(remaining_armies, fn %{id: id} -> id == defender_id end)
        else
          remaining_armies
          |> Enum.map(fn
            %{id: ^defender_id} = d -> %{d | units: remaining_units}
            d -> d
          end)
        end
      else
        remaining_armies
      end
    end)
  end

  defp sort_selection(armies) do
    armies
    |> Enum.sort_by(
      fn %{initiative: initiative} = army ->
        {calculate_effective_power(army), initiative}
      end,
      :desc
    )
  end

  defp sort_attacks(selected_targets, armies) do
    selected_targets
    |> Enum.sort_by(
      fn {attacker_id, _defender_id} ->
        attacker = Enum.find(armies, fn %{id: id} -> id == attacker_id end)
        attacker.initiative
      end,
      :desc
    )
  end

  defp resolve_attack(damage, %{units: units, hit_points: hit_points}) do
    killed_units = div(damage, hit_points)
    max(units - killed_units, 0)
  end

  defp calculate_damage(attacker, defender) do
    ap = calculate_effective_power(attacker)

    cond do
      attacker.attack_type in defender.weaknesses -> ap * 2
      attacker.attack_type in defender.immunities -> 0
      true -> ap
    end
  end

  defp process_selection_phase(armies) do
    armies = sort_selection(armies)
    infection = get_army(armies, :infection)
    immune_system = get_army(armies, :immune_system)

    infection_to_immune_system = do_process_selection_phase(infection, immune_system, [])
    immune_system_to_infection = do_process_selection_phase(immune_system, infection, [])
    infection_to_immune_system ++ immune_system_to_infection
  end

  defp do_process_selection_phase([], _defenders, attacks), do: Enum.reverse(attacks)
  defp do_process_selection_phase(_attackers, [], attacks), do: Enum.reverse(attacks)

  defp do_process_selection_phase([attacker | rest], defenders, attacks) do
    case select_target(attacker, defenders) do
      nil ->
        do_process_selection_phase(rest, defenders, attacks)

      {attacker_id, target_id} ->
        remaining_defenders = Enum.reject(defenders, fn %{id: id} -> id == target_id end)

        do_process_selection_phase(rest, remaining_defenders, [{attacker_id, target_id} | attacks])
    end
  end

  defp select_target(attacker, defenders) do
    case defenders
         |> Enum.map(fn %{id: id, initiative: initiative} = defender ->
           {id, initiative, calculate_effective_power(defender),
            calculate_damage(attacker, defender)}
         end)
         |> Enum.reject(fn {_, _, _, damage} -> damage == 0 end) do
      [] ->
        nil

      valid_targets ->
        target =
          valid_targets
          |> Enum.max_by(fn {_, initiative, ap_def, damage} -> {damage, ap_def, initiative} end)
          |> elem(0)

        {attacker.id, target}
    end
  end

  defp get_army(list, side) do
    Enum.filter(list, fn %{id: {s, _}} -> s == side end)
  end

  defp parse(input) do
    [immune_system_str, infection_str] = String.split(input, "\n\n")

    immune_system =
      immune_system_str
      |> String.split("\n")
      |> Enum.drop(1)
      |> Enum.reduce([], &parse_army/2)
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {army, idx} -> Map.put(army, :id, {:immune_system, idx}) end)

    infection =
      infection_str
      |> String.split("\n")
      |> Enum.drop(1)
      |> Enum.reduce([], &parse_army/2)
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.map(fn {army, idx} -> Map.put(army, :id, {:infection, idx}) end)

    immune_system ++ infection
  end

  defp calculate_effective_power(%{units: units, attack: attack}), do: units * attack

  defp parse_army(line, armies) do
    re =
      ~r/^(?<units>[0-9]+) units each with (?<hit_points>[0-9]+) hit points (\((?:(?:weak to (?<weaknesses>[a-z, ]+)|immune to (?<immunities>[a-z, ]+))(?:; )?){1,2}\) )?with an attack that does (?<attack>[0-9]+) (?<attack_type>[a-z]+) damage at initiative (?<initiative>[0-9]+)$/

    army =
      Regex.named_captures(re, line)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})
      |> parse_attack()
      |> parse_attack_type()
      |> parse_hit_points()
      |> parse_immunities()
      |> parse_initiative()
      |> parse_units()
      |> parse_weaknesses()

    [army | armies]
  end

  defp parse_attack(%{attack: attack_str} = army) do
    %{army | attack: String.to_integer(attack_str)}
  end

  defp parse_attack_type(%{attack_type: at_str} = army) do
    %{army | attack_type: parse_type(at_str)}
  end

  defp parse_initiative(%{initiative: i_str} = army) do
    %{army | initiative: String.to_integer(i_str)}
  end

  defp parse_units(%{units: units_str} = army) do
    %{army | units: String.to_integer(units_str)}
  end

  defp parse_hit_points(%{hit_points: hp_str} = army) do
    %{army | hit_points: String.to_integer(hp_str)}
  end

  defp parse_weaknesses(%{weaknesses: ""} = army), do: %{army | weaknesses: []}

  defp parse_weaknesses(%{weaknesses: w_str} = army) do
    weaknesses =
      w_str
      |> String.split(", ")
      |> Enum.map(&parse_type/1)

    %{army | weaknesses: weaknesses}
  end

  defp parse_immunities(%{immunities: ""} = army), do: %{army | immunities: []}

  defp parse_immunities(%{immunities: i_str} = army) do
    immunities =
      i_str
      |> String.split(", ")
      |> Enum.map(&parse_type/1)

    %{army | immunities: immunities}
  end

  defp parse_type(type_str) do
    case type_str do
      "bludgeoning" -> :bludgeoning
      "cold" -> :cold
      "fire" -> :fire
      "radiation" -> :radiation
      "slashing" -> :slashing
    end
  end
end
