defmodule Day21.ChronalConversion do
  import Bitwise

  def part1, do: solve(&part1_with_input/1)
  def part2, do: solve(&part2_with_input/1)

  defp solve(solver_fn) do
    File.read!("priv/day21/input.txt")
    |> String.trim()
    |> solver_fn.()
  end

  def part1_with_input(input) do
    {ip, instructions} = parse(input)
    find_min_value(instructions, ip)
  end

  def part2_with_input(input) do
    {ip, instructions} = parse(input)
    find_max_value(instructions, ip)
  end

  defp init_registers(val_0 \\ 0) do
    0..5
    |> Enum.zip([val_0, 0, 0, 0, 0, 0])
    |> Enum.into(%{})
  end

  defp find_min_value(instructions, ip) do
    Stream.cycle([true])
    |> Enum.reduce_while(init_registers(), fn _, current_registers ->
      current_ip = Map.get(current_registers, ip)

      if comparison_instruction?(current_ip) do
        {:halt, Map.get(current_registers, 4)}
      else
        updated_registers =
          instructions
          |> Map.get(current_ip)
          |> execute(current_registers)
          |> increase_ip(ip)

        {:cont, updated_registers}
      end
    end)
  end

  defp comparison_instruction?(ip), do: ip == 30

  defp find_max_value(instructions, ip) do
    Stream.cycle([true])
    |> Enum.reduce_while({init_registers(), [], nil}, fn _,
                                                         {current_registers, r4_values, last_r4} ->
      current_ip = Map.get(current_registers, ip)

      if comparison_instruction?(current_ip) do
        r4_value = Map.get(current_registers, 4)

        if r4_value in r4_values do
          {:halt, last_r4}
        else
          updated_registers =
            instructions
            |> Map.get(current_ip)
            |> execute(current_registers)
            |> increase_ip(ip)

          IO.puts("#{r4_value}")
          {:cont, {updated_registers, [r4_value | r4_values], r4_value}}
        end
      else
        updated_registers =
          instructions
          |> Map.get(current_ip)
          |> execute(current_registers)
          |> increase_ip(ip)

        {:cont, {updated_registers, r4_values, last_r4}}
      end
    end)
  end

  def run(instructions, ip, val_0) do
    Stream.cycle([true])
    |> Enum.reduce_while(init_registers(val_0), fn _, current_registers ->
      IO.inspect(current_registers)
      current_ip = Map.get(current_registers, ip)

      case Map.get(instructions, current_ip) do
        nil ->
          {:halt, current_registers}

        ins ->
          updated_registers =
            execute(ins, current_registers)
            |> increase_ip(ip)

          {:cont, updated_registers}
      end
    end)
  end

  defp increase_ip(registers, ip) do
    Map.update!(registers, ip, &(&1 + 1))
  end

  defp execute({:addr, a, b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a) + Map.fetch!(registers, b))
  end

  defp execute({:addi, a, b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a) + b)
  end

  defp execute({:mulr, a, b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a) * Map.fetch!(registers, b))
  end

  defp execute({:muli, a, b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a) * b)
  end

  defp execute({:banr, a, b, c}, registers) do
    Map.put(registers, c, band(Map.fetch!(registers, a), Map.fetch!(registers, b)))
  end

  defp execute({:bani, a, b, c}, registers) do
    Map.put(registers, c, band(Map.fetch!(registers, a), b))
  end

  defp execute({:borr, a, b, c}, registers) do
    Map.put(registers, c, bor(Map.fetch!(registers, a), Map.fetch!(registers, b)))
  end

  defp execute({:bori, a, b, c}, registers) do
    Map.put(registers, c, bor(Map.fetch!(registers, a), b))
  end

  defp execute({:setr, a, _b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a))
  end

  defp execute({:seti, a, _b, c}, registers) do
    Map.put(registers, c, a)
  end

  defp execute({:gtir, a, b, c}, registers) do
    if a > Map.fetch!(registers, b) do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  defp execute({:gtri, a, b, c}, registers) do
    if Map.fetch!(registers, a) > b do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  defp execute({:gtrr, a, b, c}, registers) do
    if Map.fetch!(registers, a) > Map.fetch!(registers, b) do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  defp execute({:eqir, a, b, c}, registers) do
    if a == Map.fetch!(registers, b) do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  defp execute({:eqri, a, b, c}, registers) do
    if Map.fetch!(registers, a) == b do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  defp execute({:eqrr, a, b, c}, registers) do
    if Map.fetch!(registers, a) == Map.fetch!(registers, b) do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  defp parse(input) do
    [ip_str, instructions_str] = String.split(input, "\n", parts: 2)

    ip = parse_ip(ip_str)

    instructions =
      instructions_str
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(%{}, &parse_instruction/2)

    {ip, instructions}
  end

  defp parse_ip(ip_str) do
    ip_str
    |> String.split(" ", trim: true)
    |> Enum.at(1)
    |> String.to_integer()
  end

  defp parse_instruction({ins_str, ins_num}, instructions) do
    [op_str, ops_str] = String.split(ins_str, " ", parts: 2)

    [a, b, c] =
      ops_str
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    ins = {op_str |> String.to_atom(), a, b, c}
    Map.put(instructions, ins_num, ins)
  end
end
