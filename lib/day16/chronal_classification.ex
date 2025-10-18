defmodule Day16.ChronalClassification do
  import Bitwise

  defmodule Sample do
    defstruct [:input, :op, :output]
  end

  def part1() do
    with {:ok, input} <- File.read("priv/day16/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    parse(input)
    |> elem(0)
    |> map_opcodes()
    |> Enum.count(fn mapped_opcodes -> length(mapped_opcodes) >= 3 end)
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day16/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    {samples, test_program} = parse(input)
    opcodes_map = find_opcodes(samples)

    test_program
    |> Enum.map(fn [opcode | rest] ->
      [Map.fetch!(opcodes_map, opcode) | rest] |> List.to_tuple()
    end)
    |> Enum.reduce(%{0 => 0, 1 => 0, 2 => 0, 3 => 0}, fn ins, regs ->
      execute(ins, regs)
    end)
    |> Map.fetch!(0)
  end

  defp find_opcodes(samples) do
    Stream.cycle([1])
    |> Enum.reduce_while(%{}, fn _, correct_matches ->
      if map_size(correct_matches) == 16 do
        {:halt, correct_matches}
      else
        new_correct_matches =
          samples
          |> map_opcodes(correct_matches)
          |> get_correct_opcodes()

        {:cont, new_correct_matches}
      end
    end)
  end

  defp map_opcodes(samples, correct_matches \\ %{}) do
    samples
    |> Enum.map(fn sample ->
      [
        :addr,
        :addi,
        :mulr,
        :muli,
        :banr,
        :bani,
        :borr,
        :bori,
        :setr,
        :seti,
        :gtir,
        :gtri,
        :gtrr,
        :eqir,
        :eqri,
        :eqrr
      ]
      |> Enum.reduce_while([], fn op, correct_behaviours ->
        [opcode | rest] = sample.op
        modified_op = [op | rest] |> List.to_tuple()

        cond do
          Map.has_key?(correct_matches, opcode) ->
            {:halt, [{opcode, Map.get(correct_matches, opcode)}]}

          op in Map.values(correct_matches) ->
            {:cont, correct_behaviours}

          execute(modified_op, sample.input) == sample.output ->
            {:cont, [{opcode, op} | correct_behaviours]}

          true ->
            {:cont, correct_behaviours}
        end
      end)
    end)
  end

  defp get_correct_opcodes(behaviours) do
    behaviours
    |> Enum.filter(fn mapped_opcodes -> length(mapped_opcodes) == 1 end)
    |> Enum.map(fn [{opcode, op}] -> {opcode, op} end)
    |> Enum.sort_by(fn {opcode, op} -> {opcode, op} end)
    |> Enum.dedup()
    |> Enum.into(%{})
  end

  defp execute({:addr, reg_a, reg_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> registers[reg_a] + registers[reg_b] end)
  end

  defp execute({:addi, reg_a, val_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> registers[reg_a] + val_b end)
  end

  defp execute({:mulr, reg_a, reg_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> registers[reg_a] * registers[reg_b] end)
  end

  defp execute({:muli, reg_a, val_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> registers[reg_a] * val_b end)
  end

  defp execute({:banr, reg_a, reg_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> band(registers[reg_a], registers[reg_b]) end)
  end

  defp execute({:bani, reg_a, val_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> band(registers[reg_a], val_b) end)
  end

  defp execute({:borr, reg_a, reg_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> bor(registers[reg_a], registers[reg_b]) end)
  end

  defp execute({:bori, reg_a, val_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> bor(registers[reg_a], val_b) end)
  end

  defp execute({:setr, reg_a, _, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> registers[reg_a] end)
  end

  defp execute({:seti, val_a, _, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> val_a end)
  end

  defp execute({:gtir, val_a, reg_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> if val_a > registers[reg_b], do: 1, else: 0 end)
  end

  defp execute({:gtri, reg_a, val_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> if registers[reg_a] > val_b, do: 1, else: 0 end)
  end

  defp execute({:gtrr, reg_a, reg_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ ->
      if registers[reg_a] > registers[reg_b], do: 1, else: 0
    end)
  end

  defp execute({:eqir, val_a, reg_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> if val_a == registers[reg_b], do: 1, else: 0 end)
  end

  defp execute({:eqri, reg_a, val_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ -> if registers[reg_a] == val_b, do: 1, else: 0 end)
  end

  defp execute({:eqrr, reg_a, reg_b, reg_c}, registers) do
    Map.update!(registers, reg_c, fn _ ->
      if registers[reg_a] == registers[reg_b], do: 1, else: 0
    end)
  end

  defp parse(input) do
    [samples_str, test_program_str] = String.split(input, "\n\n\n\n", trim: true)

    {parse_samples(samples_str), parse_test_program(test_program_str)}
  end

  defp parse_test_program(test_program_str) do
    test_program_str
    |> String.split("\n", trim: true)
    |> Enum.map(fn ins_str -> String.split(ins_str, " ", trim: true) end)
    |> Enum.map(fn ins -> Enum.map(ins, &String.to_integer/1) end)
  end

  defp parse_samples(samples_str) do
    samples_str
    |> String.split("\n\n")
    |> Enum.map(&parse_sample/1)
  end

  defp parse_sample(sample_str) do
    sample_str
    |> String.split("\n")
    |> Enum.reduce(%Sample{}, &parse_sample_str/2)
  end

  defp parse_sample_str("Before: " <> sample_input_str, sample) do
    input_reg =
      sample_input_str
      |> String.trim_leading("[")
      |> String.trim_trailing("]")
      |> String.split(", ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> to_registers()

    %{sample | input: input_reg}
  end

  defp parse_sample_str("After:  " <> sample_output_str, sample) do
    output_reg =
      sample_output_str
      |> String.trim_leading("[")
      |> String.trim_trailing("]")
      |> String.split(", ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> to_registers()

    %{sample | output: output_reg}
  end

  defp parse_sample_str(sample_op_str, sample) do
    op =
      sample_op_str
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    %{sample | op: op}
  end

  defp to_registers(l) do
    l
    |> Enum.with_index()
    |> Enum.map(fn {v, idx} -> {idx, v} end)
    |> Enum.into(%{})
  end
end
