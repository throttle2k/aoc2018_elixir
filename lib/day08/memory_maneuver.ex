defmodule Day08.MemoryManeuver do
  defmodule TreeNode do
    defstruct [:child_nodes, :metadata]

    def new(child_nodes, metadata) do
      %__MODULE__{child_nodes: child_nodes, metadata: metadata}
    end
  end

  def part1() do
    with {:ok, input} <- File.read("priv/day08/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    parse(input)
    |> sum_tree()
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day08/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    parse(input)
    |> value_of_root()
  end

  defp sum_tree(%TreeNode{} = tree) do
    Enum.sum(tree.metadata) +
      Enum.reduce(tree.child_nodes, 0, fn child, s -> s + sum_tree(child) end)
  end

  defp value_of_root(%TreeNode{child_nodes: []} = tree), do: Enum.sum(tree.metadata)

  defp value_of_root(%TreeNode{} = tree) do
    tree.metadata
    |> Enum.reduce(0, fn num_child, sum ->
      case Enum.at(tree.child_nodes, num_child - 1) do
        nil -> sum + 0
        child -> sum + value_of_root(child)
      end
    end)
  end

  defp parse(input) do
    input
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> parse_tree()
    |> elem(0)
  end

  defp parse_tree([0 | [metadata_length | metadata]]) do
    {TreeNode.new([], Enum.take(metadata, metadata_length)), Enum.drop(metadata, metadata_length)}
  end

  defp parse_tree([child_num | [metadata_length | rest]]) do
    {children, updated_queue} =
      1..child_num
      |> Enum.reduce({[], rest}, fn _, {acc, queue} ->
        {child, updated_queue} = parse_tree(queue)
        {[child | acc], updated_queue}
      end)

    {TreeNode.new(Enum.reverse(children), Enum.take(updated_queue, metadata_length)),
     Enum.drop(updated_queue, metadata_length)}
  end
end
