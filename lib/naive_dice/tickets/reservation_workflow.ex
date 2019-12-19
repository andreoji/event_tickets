defmodule NaiveDice.Tickets.Reservation.Workflow do
  alias NaiveDice.{Accounts, Tickets}
  
  def run(name, user, event) do
    with  {:ok, ^user} <- user |> Accounts.check_name(name),
          false <- user |> Tickets.has_ticket(event),
          false <- event |> Tickets.is_sold_out,
          {:ok, reservation} <- user |> Tickets.upsert_reservation do
            {:ok, _auto_id} = reservation |> Tickets.set_reservation_expiry
    end
  end
end