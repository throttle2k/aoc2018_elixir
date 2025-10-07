defmodule Day07.TheSumOfItsParts do
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, instructions ->
      {from, to} = parse_line(line)
      Map.update(instructions, from, [to], &[to | &1])
    end)
  end

  defp parse_line(
         "Step " <>
           <<from::binary-size(1)>> <>
           " must be finished before step " <>
           <<to::binary-size(1)>> <>
           " can begin."
       ) do
    {from, to}
  end
end
