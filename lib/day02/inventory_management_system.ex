defmodule Day02.InventoryManagementSystem do
  def part1() do
    with {:ok, input} <- File.read("priv/day02/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&Enum.frequencies/1)
    |> Enum.reduce({0, 0}, fn freq, {twos, threes} ->
      new_twos = if Enum.any?(freq, fn {_k, count} -> count == 2 end), do: twos + 1, else: twos

      new_threes =
        if Enum.any?(freq, fn {_k, count} -> count == 3 end), do: threes + 1, else: threes

      {new_twos, new_threes}
    end)
    |> then(fn {twos, threes} -> twos * threes end)
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day02/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    ids =
      input
      |> String.split("\n", trim: true)

    for s1 <- ids,
        s2 <- ids,
        s1 < s2 do
      {s1, s2}
    end
    |> Enum.find(&differ_by_one?/1)
    |> common_chars()
  end

  defp differ_by_one?({s1, s2}) do
    cs1 = String.graphemes(s1)
    cs2 = String.graphemes(s2)

    cs1
    |> Enum.zip(cs2)
    |> Enum.filter(fn {c1, c2} -> c1 != c2 end)
    |> Enum.count()
    |> Kernel.==(1)
  end

  defp common_chars({s1, s2}) do
    cs1 = String.graphemes(s1)
    cs2 = String.graphemes(s2)

    Enum.reduce(cs1, {"", cs2}, fn c1, {same, [c2 | rest]} ->
      if c1 == c2, do: {same <> c1, rest}, else: {same, rest}
    end)
    |> elem(0)
  end
end
