defmodule Day07.TheSumOfItsParts.Part2 do
  alias Day07.TheSumOfItsParts
  alias Day07.TheSumOfItsParts.Worker

  def part2() do
    with {:ok, input} <- File.read("priv/day07/input.txt") do
      part2_with_input(input)
    end
  end

  def part2_with_input(input, num_workers \\ 5, basic_step_duration \\ 60) do
    TheSumOfItsParts.parse(input)
    |> process(num_workers, basic_step_duration)
  end

  defp process(instructions, num_workers, basic_step_duration) do
    workers =
      1..num_workers
      |> Enum.map(fn _ ->
        {:ok, worker_pid} = Worker.start_link(basic_step_duration)
        {worker_pid, :idle}
      end)
      |> Enum.into(%{})

    dependencies = build_dependencies(instructions)

    next_steps = get_next_steps(dependencies)
    do_process(dependencies, next_steps, workers, MapSet.new(), 0, true)
  end

  defp do_process(%{} = dependencies, [], _workers, in_progress, time, _first_iteration)
       when map_size(dependencies) == 0 and in_progress == %MapSet{},
       do: time

  defp do_process(dependencies, queue, workers, in_progress, time, first_iteration) do
    {updated_workers, remaining_queue, updated_in_progress, updated_dependencies} =
      if first_iteration do
        {w1, q1, ip1} = assign_tasks(queue, workers, in_progress)
        {w2, deps2, ip2} = tick_workers(w1, dependencies, ip1)
        {w2, q1, ip2, deps2}
      else
        {w1, deps1, ip1} = tick_workers(workers, dependencies, in_progress)

        next_steps =
          get_next_steps(deps1)
          |> Enum.reject(fn step -> MapSet.member?(ip1, step) end)

        updated_q = Enum.concat(queue, next_steps) |> Enum.sort() |> Enum.dedup()

        {w2, q2, ip2} = assign_tasks(updated_q, w1, ip1)
        {w2, q2, ip2, deps1}
      end

    next_steps =
      get_next_steps(updated_dependencies)
      |> Enum.reject(fn step -> MapSet.member?(updated_in_progress, step) end)

    updated_queue = Enum.concat(remaining_queue, next_steps) |> Enum.sort() |> Enum.dedup()

    do_process(
      updated_dependencies,
      updated_queue,
      updated_workers,
      updated_in_progress,
      time + 1,
      false
    )
  end

  defp assign_tasks(queue, workers, in_progress) do
    queue
    |> Enum.reduce({workers, queue, in_progress}, fn step,
                                                     {current_workers, current_queue,
                                                      current_in_progress} ->
      case get_free_worker(current_workers) do
        nil ->
          {current_workers, current_queue, current_in_progress}

        {pid, _} ->
          Worker.start_step(pid, step)

          {Map.put(current_workers, pid, :working), List.delete(current_queue, step),
           MapSet.put(current_in_progress, step)}
      end
    end)
  end

  defp tick_workers(workers, dependencies, in_progress) do
    {updated_workers, completed_steps, updated_in_progress} =
      workers
      |> Enum.reduce({workers, [], in_progress}, fn {pid, _},
                                                    {current_workers, current_completed,
                                                     current_in_progress} ->
        case Worker.tick(pid) do
          :idle ->
            {current_workers, current_completed, current_in_progress}

          {:done, step} ->
            {Map.put(current_workers, pid, :idle), [step | current_completed],
             MapSet.delete(current_in_progress, step)}

          :working ->
            {current_workers, current_completed, current_in_progress}
        end
      end)

    updated_dependencies =
      Enum.reduce(completed_steps, dependencies, fn step, current_deps ->
        remove_step(current_deps, step)
      end)

    {updated_workers, updated_dependencies, updated_in_progress}
  end

  defp get_free_worker(workers) do
    workers
    |> Enum.find(fn {_, state} -> state == :idle end)
  end

  defp get_next_steps(dependencies) do
    dependencies
    |> Enum.filter(fn {_node, deps} -> deps == [] end)
    |> Enum.map(fn {node, _} -> node end)
    |> Enum.sort()
  end

  defp remove_step(dependencies, step) do
    dependencies
    |> Map.delete(step)
    |> Enum.map(fn {k, deps} -> {k, List.delete(deps, step)} end)
    |> Enum.into(%{})
  end

  defp build_dependencies(instructions) do
    all_nodes =
      instructions
      |> Enum.flat_map(fn {k, v} -> [k | v] end)
      |> Enum.uniq()

    all_nodes
    |> Enum.map(fn node ->
      deps =
        instructions
        |> Enum.filter(fn {_k, v} -> node in v end)
        |> Enum.map(fn {k, _v} -> k end)

      {node, deps}
    end)
    |> Enum.into(%{})
  end
end
