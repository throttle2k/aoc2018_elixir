defmodule Day14.ChocolateCharts do
  @input 513_401
  @input2 "513401"

  def part1(input \\ @input) do
    initial_scores = %{0 => 3, 1 => 7}

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({initial_scores, 0, 1}, fn _, {scores, p1, p2} ->
      if map_size(scores) >= input + 10 do
        {:halt, get_result(scores, input)}
      else
        {:cont, add_recipe(scores, p1, p2)}
      end
    end)
  end

  def part2(input_str \\ @input2) do
    initial_scores = %{0 => 3, 1 => 7}
    target = String.graphemes(input_str) |> Enum.map(&String.to_integer/1)
    target_len = length(target)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({initial_scores, 0, 1}, fn _, {scores, p1, p2} ->
      size = map_size(scores)

      cond do
        size >= target_len and matches_at?(scores, target, size - target_len) ->
          {:halt, size - target_len}

        size >= target_len + 1 and matches_at?(scores, target, size - target_len - 1) ->
          {:halt, size - target_len - 1}

        true ->
          {:cont, add_recipe(scores, p1, p2)}
      end
    end)
  end

  defp matches_at?(scores, target, start_idx) do
    target
    |> Enum.with_index()
    |> Enum.all?(fn {digit, offset} ->
      Map.get(scores, start_idx + offset) == digit
    end)
  end

  defp add_recipe(scores, p1, p2) do
    score1 = Map.get(scores, p1)
    score2 = Map.get(scores, p2)
    sum = score1 + score2
    size = map_size(scores)

    updated_scores =
      if sum >= 10 do
        scores
        |> Map.put(size, 1)
        |> Map.put(size + 1, sum - 10)
      else
        Map.put(scores, size, sum)
      end

    new_size = map_size(updated_scores)
    new_p1 = rem(p1 + score1 + 1, new_size)
    new_p2 = rem(p2 + score2 + 1, new_size)

    {updated_scores, new_p1, new_p2}
  end

  defp get_result(scores, input) do
    input..(input + 9)
    |> Enum.map(&Map.get(scores, &1))
    |> Enum.join()
  end
end
