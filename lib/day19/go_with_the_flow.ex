defmodule Day19.GoWithTheFlow do
  import Bitwise

  def part1() do
    with {:ok, input} <- File.read("priv/day19/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    {ip, instructions} =
      input
      |> parse()

    run(ip, instructions, init_registers())
    |> Map.get(0)
  end

  @doc """

  Rows 1-16
  addi 4 16 4      # jump to row 17 
  seti 1 4 3       # r3 = 1
  seti 1 3 5       # r5 = 1
  mulr 3 5 1       # r1 = r3 * r5
  eqrr 1 2 1       # if r1 == r2, r1 = 1, else r1 = 0
  addr 1 4 4       # if r1 == 1, jump ahead
  addi 4 1 4       # else continue
  addr 3 0 0       # r0 += r3
  addi 5 1 5       # r5 += 1
  gtrr 5 2 1       # if r5 > r2, r1 = 1
  addr 4 1 4       # if true, jump
  seti 2 9 4       # back to row 2
  addi 3 1 3       # r3 += 1
  gtrr 3 2 1       # if r3 > r2, r1 = 1
  addr 1 4 4       # if true, jump
  seti 1 6 4       # back to row 1

  For every couple (r3, r5) where r3*r5 == r2, increase r0 by r3. i.e. sum every divisor of r2

  Rows 17-29 calculate the value of r2
  mulr 4 4 4       # r4 *= r4 (quadrato del PC)
  addi 2 2 2       # r2 += 2
  mulr 2 2 2       # r2 *= r2
  mulr 4 2 2       # r2 *= r4
  muli 2 11 2      # r2 *= 11
  addi 1 2 1       # r1 += 2
  mulr 1 4 1       # r1 *= r4
  addi 1 7 1       # r1 += 7
  addr 2 1 2       # r2 += r1

  After some iterations the value for my input is 10_551_287
  """
  def part2() do
    sum_of_divisors(10_551_287)
  end

  defp init_registers() do
    0..5
    |> Enum.map(fn reg -> {reg, 0} end)
    |> Enum.into(%{})
  end

  defp get_instruction(ip, instructions, registers) do
    ins = Map.get(registers, ip)
    Map.get(instructions, ins)
  end

  defp move_pointer(registers, ip) do
    Map.update!(registers, ip, &(&1 + 1))
  end

  defp run(ip, instructions, initial_registers) do
    Stream.cycle([true])
    |> Enum.reduce_while(initial_registers, fn _, registers ->
      case get_instruction(ip, instructions, registers) do
        nil ->
          {:halt, registers}

        op ->
          updated_registers =
            execute(op, registers)
            |> move_pointer(ip)

          {:cont, updated_registers}
      end
    end)
  end

  def sum_of_divisors(n) do
    1..trunc(:math.sqrt(n))
    |> Enum.reduce(0, fn i, acc ->
      case rem(n, i) do
        0 ->
          divisor2 = div(n, i)
          acc + i + if i != divisor2, do: divisor2, else: 0

        _ ->
          acc
      end
    end)
  end

  def execute({:addr, a, b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a) + Map.fetch!(registers, b))
  end

  def execute({:addi, a, b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a) + b)
  end

  def execute({:mulr, a, b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a) * Map.fetch!(registers, b))
  end

  def execute({:muli, a, b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a) * b)
  end

  def execute({:banr, a, b, c}, registers) do
    Map.put(registers, c, band(Map.fetch!(registers, a), Map.fetch!(registers, b)))
  end

  def execute({:bani, a, b, c}, registers) do
    Map.put(registers, c, band(Map.fetch!(registers, a), b))
  end

  def execute({:borr, a, b, c}, registers) do
    Map.put(registers, c, bor(Map.fetch!(registers, a), Map.fetch!(registers, b)))
  end

  def execute({:bori, a, b, c}, registers) do
    Map.put(registers, c, bor(Map.fetch!(registers, a), b))
  end

  def execute({:setr, a, _b, c}, registers) do
    Map.put(registers, c, Map.fetch!(registers, a))
  end

  def execute({:seti, a, _b, c}, registers) do
    Map.put(registers, c, a)
  end

  def execute({:gtir, a, b, c}, registers) do
    if a > Map.fetch!(registers, b) do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  def execute({:gtri, a, b, c}, registers) do
    if Map.fetch!(registers, a) > b do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  def execute({:gtrr, a, b, c}, registers) do
    if Map.fetch!(registers, a) > Map.fetch!(registers, b) do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  def execute({:eqir, a, b, c}, registers) do
    if a == Map.fetch!(registers, b) do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  def execute({:eqri, a, b, c}, registers) do
    if Map.fetch!(registers, a) == b do
      Map.put(registers, c, 1)
    else
      Map.put(registers, c, 0)
    end
  end

  def execute({:eqrr, a, b, c}, registers) do
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
