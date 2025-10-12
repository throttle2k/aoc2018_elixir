defmodule Day13.MineCartMadness do
  defmodule Cart do
    defstruct [:id, :pos, :dir, :turns]

    @type direction :: :n | :s | :e | :w
    @type turn_state :: 0 | 1 | 2
    @type t :: %__MODULE__{
            id: integer(),
            pos: {integer(), integer()},
            dir: direction(),
            turns: turn_state()
          }

    def new(id, pos, dir) do
      %__MODULE__{id: id, pos: pos, dir: dir, turns: 0}
    end
  end

  def part1() do
    with {:ok, input} <- File.read("priv/day13/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    {track, carts} = parse(input)
    find_first_crash(track, carts)
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day13/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    {track, carts} = parse(input)
    find_last_cart(track, carts)
  end

  defp find_first_crash(track, carts) do
    {new_carts, crashes} = tick(track, carts, false)

    if MapSet.size(crashes) > 0 do
      crashed_cart = Enum.find(new_carts, fn c -> c.id in crashes end)
      format_position(crashed_cart.pos)
    else
      find_first_crash(track, new_carts)
    end
  end

  defp find_last_cart(_track, carts) when length(carts) == 1 do
    format_position(hd(carts).pos)
  end

  defp find_last_cart(track, carts) do
    {new_carts, _crashes} = tick(track, carts, true)

    case length(new_carts) do
      0 -> raise "No carts remaining!"
      1 -> format_position(hd(new_carts).pos)
      _ -> find_last_cart(track, new_carts)
    end
  end

  def parse(input) do
    lines = String.split(input, "\n", trim: true)

    {track, carts} =
      lines
      |> Enum.with_index()
      |> Enum.reduce({%{}, []}, fn {line, row}, acc ->
        parse_line(line, row, acc)
      end)

    {track, Enum.reverse(carts)}
  end

  defp parse_line(line, row, {track, carts}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce({track, carts}, fn {char, col}, {t, c} ->
      pos = {row, col}

      case char do
        "|" -> {Map.put(t, pos, :vertical), c}
        "-" -> {Map.put(t, pos, :horizontal), c}
        "/" -> {Map.put(t, pos, :slash), c}
        "\\" -> {Map.put(t, pos, :backslash), c}
        "+" -> {Map.put(t, pos, :intersection), c}
        "^" -> {Map.put(t, pos, :vertical), [Cart.new(length(c), pos, :n) | c]}
        "v" -> {Map.put(t, pos, :vertical), [Cart.new(length(c), pos, :s) | c]}
        "<" -> {Map.put(t, pos, :horizontal), [Cart.new(length(c), pos, :w) | c]}
        ">" -> {Map.put(t, pos, :horizontal), [Cart.new(length(c), pos, :e) | c]}
        _ -> {t, c}
      end
    end)
  end

  def move_cart(%Cart{pos: pos, dir: dir} = cart, track) do
    new_pos = step(pos, dir)

    track_type = Map.fetch!(track, new_pos)
    new_dir = turn(dir, track_type, cart.turns)
    new_turns = next_turn_state(cart.turns, track_type)

    %{cart | pos: new_pos, dir: new_dir, turns: new_turns}
  end

  defp step({r, c}, :n), do: {r - 1, c}
  defp step({r, c}, :s), do: {r + 1, c}
  defp step({r, c}, :e), do: {r, c + 1}
  defp step({r, c}, :w), do: {r, c - 1}

  defp turn(dir, :vertical, _), do: dir
  defp turn(dir, :horizontal, _), do: dir

  defp turn(:n, :slash, _), do: :e
  defp turn(:s, :slash, _), do: :w
  defp turn(:e, :slash, _), do: :n
  defp turn(:w, :slash, _), do: :s

  defp turn(:n, :backslash, _), do: :w
  defp turn(:s, :backslash, _), do: :e
  defp turn(:e, :backslash, _), do: :s
  defp turn(:w, :backslash, _), do: :n

  defp turn(:n, :intersection, 0), do: :w
  defp turn(:n, :intersection, 1), do: :n
  defp turn(:n, :intersection, 2), do: :e

  defp turn(:s, :intersection, 0), do: :e
  defp turn(:s, :intersection, 1), do: :s
  defp turn(:s, :intersection, 2), do: :w

  defp turn(:e, :intersection, 0), do: :n
  defp turn(:e, :intersection, 1), do: :e
  defp turn(:e, :intersection, 2), do: :s

  defp turn(:w, :intersection, 0), do: :s
  defp turn(:w, :intersection, 1), do: :w
  defp turn(:w, :intersection, 2), do: :n

  defp next_turn_state(turns, :intersection), do: rem(turns + 1, 3)
  defp next_turn_state(turns, _), do: turns

  def tick(track, carts, remove_crashed \\ false) do
    sorted = Enum.sort_by(carts, fn %Cart{pos: {r, c}} -> {r, c} end)

    {moved, crashes} =
      sorted
      |> Enum.with_index()
      |> Enum.reduce({[], MapSet.new()}, fn {cart, idx}, {moved, crashed} ->
        if cart.id in crashed do
          {moved, crashed}
        else
          new_cart = move_cart(cart, track)

          collision_with_moved =
            Enum.find(moved, fn c ->
              c.pos == new_cart.pos and c.id not in crashed
            end)

          remaining_carts = Enum.drop(sorted, idx + 1)

          collision_with_unmoved =
            Enum.find(remaining_carts, fn c ->
              c.pos == new_cart.pos and c.id not in crashed
            end)

          case {collision_with_moved, collision_with_unmoved} do
            {nil, nil} ->
              {[new_cart | moved], crashed}

            {other, nil} ->
              {[new_cart | moved], MapSet.put(crashed, other.id) |> MapSet.put(new_cart.id)}

            {nil, other} ->
              {[new_cart | moved], MapSet.put(crashed, other.id) |> MapSet.put(new_cart.id)}

            {_, _} ->
              {[new_cart | moved], MapSet.put(crashed, new_cart.id)}
          end
        end
      end)

    active_carts =
      if remove_crashed do
        Enum.reject(moved, fn c -> c.id in crashes end)
      else
        moved
      end

    {Enum.reverse(active_carts), crashes}
  end

  defp format_position({row, col}), do: "#{col},#{row}"
end
