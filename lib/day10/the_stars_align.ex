defmodule Day10.TheStarsAlign do
  defmodule Point do
    defstruct [:position, :velocity]

    def new({px, py}, {vx, vy}) do
      %__MODULE__{position: {px, py}, velocity: {vx, vy}}
    end

    def move(%__MODULE__{position: {x, y}, velocity: {vx, vy}} = point, steps \\ 1) do
      %{point | position: {x + vx * steps, y + vy * steps}}
    end
  end

  def part1() do
    with {:ok, input} <- File.read("priv/day10/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    points = parse(input)

    {second, aligned_points} = find_alignment(points)

    IO.puts("Messaggio trovato al secondo: #{second}")
    render(aligned_points)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    ~r/position=<\s*(?<px>-?\d+),\s*(?<py>-?\d+)> velocity=<\s*(?<vx>-?\d+),\s*(?<vy>-?\d+)>/
    |> Regex.named_captures(line)
    |> then(fn %{"px" => px, "py" => py, "vx" => vx, "vy" => vy} ->
      Point.new(
        {String.to_integer(px), String.to_integer(py)},
        {String.to_integer(vx), String.to_integer(vy)}
      )
    end)
  end

  defp find_alignment(points) do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({nil, nil, :infinity}, fn second,
                                                   {prev_second, prev_points, prev_area} ->
      moved_points = Enum.map(points, &Point.move(&1, second))
      area = calculate_bounding_area(moved_points)

      cond do
        prev_area == :infinity or area < prev_area -> {:cont, {second, moved_points, area}}
        area > prev_area -> {:halt, {prev_second, prev_points}}
        true -> {:cont, {second, moved_points, area}}
      end
    end)
  end

  defp calculate_bounding_area(points) do
    positions = Enum.map(points, & &1.position)
    {xs, ys} = Enum.unzip(positions)

    {min_x, max_x} = Enum.min_max(xs)
    {min_y, max_y} = Enum.min_max(ys)
    width = max_x - min_x
    height = max_y - min_y

    width * height
  end

  defp render(points) do
    positions = Enum.map(points, & &1.position) |> MapSet.new()
    {xs, ys} = Enum.unzip(MapSet.to_list(positions))

    {min_x, max_x} = Enum.min_max(xs)
    {min_y, max_y} = Enum.min_max(ys)

    IO.puts("\n")

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        if MapSet.member?(positions, {x, y}), do: "#", else: " "
      end
      |> IO.puts()
    end

    IO.puts("\n")
  end
end
