defmodule NaiveDice.Teardown.ExpiryTasks do
  use Agent
  
  def start_link(_args), do: Agent.start_link fn -> %{} end, name: __MODULE__

  def add_task(reservation_id, auto_id) do
    Agent.update __MODULE__,
      fn tasks ->
        if Map.has_key?(tasks, reservation_id) do
          tasks |> cancel_existing_task(reservation_id)
        end
        tasks |> Map.put(reservation_id, auto_id)
      end
  end

  def cancel_task(reservation_id) do
    (Agent.update __MODULE__,
      fn tasks ->
        _new_state =
          if Map.has_key?(tasks, reservation_id) do
            tasks |> cancel_existing_task(reservation_id)
          else
            tasks
          end
      end)
    |>
    case do
      :ok -> {:ok, :cancelled}
      error -> {:error, error}
    end
  end

  defp cancel_existing_task(tasks, reservation_id) do
    with auto_id <- tasks |> Map.get(reservation_id),
         {:ok, _result} <- auto_id |> TaskAfter.cancel_task_after do
         tasks |> Map.delete(reservation_id)
    end
    tasks |> Map.delete(reservation_id)
  end

  def cancel_all do
    (Agent.update __MODULE__,
      fn tasks ->
        _result = tasks |> Map.values |> Enum.each(&TaskAfter.cancel_task_after(&1))
        %{}
      end)
    |>
    case do
      :ok -> {:ok, :cancelled}
      error -> {:error, error}
    end
  end

  def tasks, do: Agent.get(__MODULE__, fn tasks -> tasks end)
end