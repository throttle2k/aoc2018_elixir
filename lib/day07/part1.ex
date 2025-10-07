defmodule Day07.TheSumOfItsParts.Part1 do
  alias Day07.TheSumOfItsParts

  def part1() do
    with {:ok, input} <- File.read("priv/day07/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    TheSumOfItsParts.parse(input)
    |> process()
  end

  defp process(instructions) do
    next_steps = get_next_steps(instructions)
    do_process(instructions, next_steps, "")
  end

  defp do_process(%{} = instructions, [], sequence) when map_size(instructions) == 0, do: sequence

  defp do_process(instructions, [next | rest], sequence) do
    updated_instructions = remove_step(instructions, next)
    next_steps = get_next_steps(updated_instructions)

    updated_sequence =
      if Enum.empty?(updated_instructions) and Enum.empty?(next_steps) do
        last_steps =
          instructions
          |> Map.fetch!(next)
          |> Enum.join()

        sequence <> next <> last_steps
      else
        sequence <> next
      end

    updated_queue = Enum.concat(rest, next_steps) |> Enum.sort() |> Enum.dedup()
    do_process(updated_instructions, updated_queue, updated_sequence)
  end

  defp get_next_steps(instructions) do
    instructions
    |> Enum.reject(fn {from, _to} ->
      Map.values(instructions)
      |> Enum.any?(fn set -> from in set end)
    end)
    |> Enum.map(fn {from, _} -> from end)
  end

  defp remove_step(instructions, step) do
    Map.delete(instructions, step)
  end
end
