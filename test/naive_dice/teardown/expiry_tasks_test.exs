defmodule NaiveDice.Teardown.ExpiryTasks.Test do
  use NaiveDice.DataCase
  import Ecto.Query, warn: false
  alias NaiveDice.Tickets
  alias NaiveDice.Tickets.Reservation

  describe "ExpiryTasks worker" do
    setup [:create_event, :create_users_with_active_reservations]
    
    test "Supervisor starts a new ExpiryWorker with tasks for active reservations", %{
      reservations: reservations
    }  do
      
      [%Reservation{id: reservation_1_id} | [%Reservation{id: reservation_2_id} | []]] = reservations
      [{:ok, auto_id_1}, {:ok, auto_id_2}] = for r <- reservations, do: r |> Tickets.set_reservation_expiry
      
      for {reservation_id, auto_id} <- [{reservation_1_id, auto_id_1}, {reservation_2_id, auto_id_2}],
        do: reservation_id |> NaiveDice.Teardown.ExpiryTasks.add_task(auto_id) 

      assert NaiveDice.Teardown.ExpiryTasks.tasks == %{reservation_1_id => auto_id_1, reservation_2_id => auto_id_2}
      
      [{_, pid, :worker, _}, {_, _, :supervisor, _}, {_, _, :supervisor, _}]
        = Supervisor.which_children(NaiveDice.Supervisor)
      ref = Process.monitor(pid)
      
      Process.exit(pid, :kill)
      
      receive do
        {:DOWN, ^ref, :process, ^pid, :killed} ->
          :timer.sleep 1
        [{_, new_pid, :worker, _}, {_, _, :supervisor, _}, {_, _, :supervisor, _}]
          = Supervisor.which_children(NaiveDice.Supervisor)
       
       assert new_pid != pid
       assert NaiveDice.Teardown.ExpiryTasks.tasks |> Map.keys == [reservation_1_id, reservation_2_id]
      
      after
        1000 ->
          raise :timeout
      end
      NaiveDice.Teardown.ExpiryTasks.cancel_all
    end
  end
end