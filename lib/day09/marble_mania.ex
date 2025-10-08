defmodule Day09.MarbleMania do
  defmodule Circle do
    defstruct left: [], current: 0, right: []

    def new, do: %__MODULE__{left: [], current: 0, right: []}

    def rotate_clockwise(circle, 0), do: circle

    def rotate_clockwise(%__MODULE__{right: [h | t]} = circle, n) do
      rotate_clockwise(
        %{circle | left: [circle.current | circle.left], current: h, right: t},
        n - 1
      )
    end

    def rotate_clockwise(%__MODULE__{right: [], left: left} = circle, n) do
      [h | t] = Enum.reverse([circle.current | left])
      rotate_clockwise(%{circle | left: [], current: h, right: t}, n - 1)
    end

    def rotate_counterclockwise(circle, 0), do: circle

    def rotate_counterclockwise(%__MODULE__{left: [h | t]} = circle, n) do
      rotate_counterclockwise(
        %{circle | right: [circle.current | circle.right], current: h, left: t},
        n - 1
      )
    end

    def rotate_counterclockwise(%__MODULE__{left: [], right: right} = circle, n) do
      [h | t] = Enum.reverse([circle.current | right])
      rotate_counterclockwise(%{circle | right: [], current: h, left: t}, n - 1)
    end

    def insert_after(%__MODULE__{} = circle, value) do
      %{circle | left: [circle.current | circle.left], current: value}
    end

    def remove_current(%__MODULE__{right: [h | t]} = circle) do
      {circle.current, %{circle | current: h, right: t}}
    end

    def remove_current(%__MODULE__{right: [], left: left} = circle) do
      case Enum.reverse(left) do
        [] -> {circle.current, %{circle | current: 0, left: []}}
        [h | t] -> {circle.current, %{circle | current: h, right: t, left: []}}
      end
    end
  end

  defmodule State do
    defstruct [:circle, :player_points, :current_player, :num_players]

    def new(num_players) do
      player_points = Map.new(1..num_players, fn n -> {n, 0} end)

      %__MODULE__{
        circle: Circle.new(),
        player_points: player_points,
        current_player: 1,
        num_players: num_players
      }
    end

    def next_player(%__MODULE__{current_player: current_player} = state) do
      %{state | current_player: rem(current_player, state.num_players) + 1}
    end

    def add_points(%__MODULE__{} = state, points) do
      %{
        state
        | player_points:
            Map.update(state.player_points, state.current_player, points, &(&1 + points))
      }
    end

    def play_marble(%__MODULE__{} = state, marble) when rem(marble, 23) == 0 do
      circle = Circle.rotate_counterclockwise(state.circle, 7)
      {removed_marble, new_circle} = Circle.remove_current(circle)

      state
      |> Map.put(:circle, new_circle)
      |> add_points(marble + removed_marble)
    end

    def play_marble(%__MODULE__{} = state, marble) do
      new_circle =
        state.circle
        |> Circle.rotate_clockwise(1)
        |> Circle.insert_after(marble)

      %{state | circle: new_circle}
    end
  end

  def part1(num_players \\ 465, last_marble \\ 71940) do
    Enum.reduce(1..last_marble, State.new(num_players), &play/2)
    |> Map.fetch!(:player_points)
    |> Enum.max_by(fn {_k, v} -> v end)
    |> elem(1)
  end

  def part2(num_players \\ 465, last_marble \\ 7_194_000) do
    Enum.reduce(1..last_marble, State.new(num_players), &play/2)
    |> Map.fetch!(:player_points)
    |> Enum.max_by(fn {_k, v} -> v end)
    |> elem(1)
  end

  defp play(current_marble, state) do
    state
    |> State.play_marble(current_marble)
    |> State.next_player()
  end
end
