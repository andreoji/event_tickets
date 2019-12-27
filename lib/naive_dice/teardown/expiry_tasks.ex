defmodule NaiveDice.Teardown.ExpiryTasks do
  require Logger
  alias NaiveDice.Tickets
  alias NaiveDice.Tickets.Reservation

  use Agent

  @expiry_interval Application.get_env(:naive_dice, :expiry_interval)

  def start_link(_args) do
    with {:ok, _pid} = start <- (Agent.start_link fn -> %{} end, name: __MODULE__),
          _tasks <- add_tasks_for_active_reservations() do
      start
    else
      {:error, {:already_started, _pid}} = error -> error
      error -> error
    end
  end

  def add_task(reservation_id, auto_id) do
    Agent.update __MODULE__,
      fn state ->
        if Map.has_key?(state, reservation_id) do
          state |> cancel_existing_task(reservation_id)
        end
        state |> Map.put(reservation_id, auto_id)
      end
  end

  def cancel_task(reservation_id) do
    (Agent.update __MODULE__,
      fn state ->
        _new_state =
          if Map.has_key?(state, reservation_id) do
            state |> cancel_existing_task(reservation_id)
          else
            state
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

  def add_tasks_for_active_reservations() do
    reservations = Tickets.active_reservations

    tasks_after = for r <- reservations, do: @expiry_interval
                    |> TaskAfter.task_after((fn -> r |> Tickets.expire_active_reservation end))

    tasks = Enum.zip(reservations, tasks_after)

    with :ok <- (Agent.update __MODULE__,
                  fn state ->
                    tasks |> add_tasks(state)
                  end) do
    else
      error ->
        Logger.error(inspect error)
        {:error, "Failed to add tasks to Agent on start"}
    end
  end

  defp add_tasks([], %{} = state), do: state
  defp add_tasks(tasks, state), do: do_add_tasks(tasks, state)
  defp do_add_tasks([{%Reservation{id: id}, {:ok, auto_id}}| []], state) do
    state |> Map.put(id, auto_id)
  end
  defp do_add_tasks([{%Reservation{id: id}, {:ok, auto_id}}| tasks], state) do
    state = state |> Map.put(id, auto_id)
    do_add_tasks(tasks, state)
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

  def tasks, do: Agent.get(__MODULE__, fn state -> state end)
end