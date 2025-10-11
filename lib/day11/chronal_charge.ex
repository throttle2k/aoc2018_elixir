defmodule Day11.ChronalCharge do
  @grid_size 300

  def part1(serial_number \\ 4172) do
    serial_number
    |> prepare_grid()
    |> find_max_square(3)
    |> format_result()
  end

  def part2(serial_number \\ 4172) do
    serial_number
    |> prepare_grid()
    |> create_summed_area_table()
    |> find_max_square_any_size()
    |> format_result()
  end

  defp find_max_square(grid, size) do
    1..(@grid_size - size + 1)
    |> Task.async_stream(fn x ->
      find_max_in_column(grid, x, size)
    end)
    |> Enum.reduce({:neg_infinity, nil}, fn {:ok, result}, acc ->
      max_result(result, acc)
    end)
  end

  defp find_max_in_column(grid, x, size) do
    for y <- 1..(@grid_size - size + 1), reduce: {:neg_infinity, nil} do
      acc ->
        sum = calculate_fixed_square_sum(grid, x, y, size)
        max_result({sum, {x, y}}, acc)
    end
  end

  defp calculate_fixed_square_sum(grid, x, y, size) do
    for dx <- 0..(size - 1), dy <- 0..(size - 1), reduce: 0 do
      sum -> sum + Map.fetch!(grid, {x + dx, y + dy})
    end
  end

  defp find_max_square_any_size(sat) do
    1..@grid_size
    |> Task.async_stream(
      fn size -> find_max_for_size(sat, size) end,
      timeout: :infinity
    )
    |> Enum.reduce({:neg_infinity, nil}, fn {:ok, result}, acc ->
      max_result(result, acc)
    end)
  end

  defp find_max_for_size(sat, size) do
    for x <- 1..(@grid_size - size + 1),
        y <- 1..(@grid_size - size + 1),
        reduce: {:neg_infinity, nil} do
      acc ->
        sum = calculate_square_sum(sat, x, y, size)
        max_result({sum, {x, y, size}}, acc)
    end
  end

  defp max_result({sum, coords}, {max_sum, _}) when sum > max_sum or max_sum == :neg_infinity do
    {sum, coords}
  end

  defp max_result(_, acc), do: acc

  defp calculate_square_sum(sat, x, y, size) do
    bottom_right = Map.fetch!(sat, {x + size - 1, y + size - 1})
    top_right = Map.get(sat, {x - 1, y + size - 1}, 0)
    bottom_left = Map.get(sat, {x + size - 1, y - 1}, 0)
    top_left = Map.get(sat, {x - 1, y - 1}, 0)
    bottom_right - top_right - bottom_left + top_left
  end

  defp prepare_grid(serial_number) do
    for x <- 1..@grid_size, y <- 1..@grid_size, into: %{} do
      {{x, y}, calculate_power_level(x, y, serial_number)}
    end
  end

  defp calculate_power_level(x, y, serial_number) do
    rack_id = x + 10

    y
    |> Kernel.*(rack_id)
    |> Kernel.+(serial_number)
    |> Kernel.*(rack_id)
    |> extract_hundreds_digit()
    |> Kernel.-(5)
  end

  defp extract_hundreds_digit(power_level) do
    power_level
    |> div(100)
    |> rem(10)
  end

  defp create_summed_area_table(grid) do
    for x <- 1..@grid_size, y <- 1..@grid_size, reduce: %{} do
      sat ->
        current = Map.fetch!(grid, {x, y})
        above = Map.get(sat, {x, y - 1}, 0)
        left = Map.get(sat, {x - 1, y}, 0)
        diagonal = Map.get(sat, {x - 1, y - 1}, 0)

        Map.put(sat, {x, y}, current + above + left - diagonal)
    end
  end

  defp format_result({_sum, {x, y, size}}), do: {x, y, size}
  defp format_result({_sum, {x, y}}), do: {x, y}
end
