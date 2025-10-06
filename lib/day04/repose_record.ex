defmodule Day04.ReposeRecord do
  def part1() do
    with {:ok, input} <- File.read("priv/day04/input.txt") do
      part1_with_input(input)
    end
  end

  def part1_with_input(input) do
    sleep_map =
      input
      |> parse()
      |> build_sleep_map()

    guard_id = find_sleepiest_guard(sleep_map)
    minute = find_sleepiest_minute_for_guard(sleep_map, guard_id)
    guard_id * minute
  end

  def part2() do
    with {:ok, input} <- File.read("priv/day04/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input) do
    {guard_id, minute, _count} =
      input
      |> parse()
      |> build_sleep_map()
      |> find_most_consistent_sleeper()

    guard_id * minute
  end

  defp find_most_consistent_sleeper(sleep_map) do
    sleep_map
    |> Enum.map(fn {guard_id, minutes} ->
      {minute, count} = Enum.max_by(minutes, fn {_min, cnt} -> cnt end)
      {guard_id, minute, count}
    end)
    |> Enum.max_by(fn {_id, _min, count} -> count end)
  end

  defp find_sleepiest_guard(sleep_map) do
    sleep_map
    |> Enum.map(fn {guard_id, minutes} ->
      total_minutes =
        minutes
        |> Map.values()
        |> Enum.sum()

      {guard_id, total_minutes}
    end)
    |> Enum.max_by(fn {_id, total} -> total end)
    |> elem(0)
  end

  defp find_sleepiest_minute_for_guard(sleep_map, guard_id) do
    sleep_map
    |> Map.fetch!(guard_id)
    |> Enum.max_by(fn {_minute, count} -> count end)
    |> elem(0)
  end

  defp build_sleep_map(events) do
    events
    |> Enum.reduce(
      %{current_guard: nil, sleep_start: nil, sleep_map: %{}},
      &process_event/2
    )
    |> Map.get(:sleep_map)
  end

  defp process_event({_time, {:begin_shift, guard_id}}, acc) do
    %{acc | current_guard: guard_id}
  end

  defp process_event({time, {:asleep}}, acc) do
    %{acc | sleep_start: time}
  end

  defp process_event({time, {:awake}}, acc) do
    minutes = get_sleep_minutes(acc.sleep_start, time)
    sleep_map = record_sleep(acc.sleep_map, acc.current_guard, minutes)
    %{acc | sleep_start: nil, sleep_map: sleep_map}
  end

  defp get_sleep_minutes(sleep_start, wake_time) do
    start_minute = sleep_start.minute
    end_minute = wake_time.minute
    Enum.to_list(start_minute..(end_minute - 1))
  end

  defp record_sleep(sleep_map, gurad_id, minutes) do
    guard_minutes = Map.get(sleep_map, gurad_id, %{})

    updated_minutes =
      Enum.reduce(minutes, guard_minutes, fn minute, acc ->
        Map.update(acc, minute, 1, &(&1 + 1))
      end)

    Map.put(sleep_map, gurad_id, updated_minutes)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.sort_by(fn {datetime, _} -> datetime end, NaiveDateTime)
  end

  defp parse_line(line) do
    [timestamp_part, event_part] = String.split(line, "] ", trim: true, parts: 2)
    datetime = parse_timestamp(timestamp_part)
    event = parse_event(event_part)

    {datetime, event}
  end

  defp parse_timestamp("[" <> timestamp_str) do
    [date_str, time_str] = String.split(timestamp_str, " ")

    date = Date.from_iso8601!(date_str)
    time = Time.from_iso8601!(time_str <> ":00")
    NaiveDateTime.new!(date, time)
  end

  defp parse_event("Guard #" <> rest) do
    [id_str | _] = String.split(rest, " ")
    {:begin_shift, String.to_integer(id_str)}
  end

  defp parse_event("falls asleep"), do: {:asleep}
  defp parse_event("wakes up"), do: {:awake}
end
