defmodule NaiveDice.Teardown.ExpiryTasks do
  require Logger
  use Agent
  
  def start_link(_args), do: Agent.start_link fn -> [] end, name: __MODULE__

  def add_task(task) do
    Agent.update __MODULE__, fn tasks -> [task| tasks] end
  end

  def cancel_all do
    (Agent.update __MODULE__, fn tasks ->
        _result = tasks |> Enum.each(&TaskAfter.cancel_task_after(&1))
        []
      end)
    |>
    case do
      :ok -> {:ok, :cancelled}
      error -> {:error, error}
    end
  end

  def tasks, do: Agent.get(__MODULE__, fn tasks -> tasks end)
end