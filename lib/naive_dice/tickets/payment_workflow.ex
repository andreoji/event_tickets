defmodule NaiveDice.Tickets.Payment.Workflow do
  alias NaiveDice.{Accounts, Tickets}
  alias NaiveDice.Tickets.Reservation
  alias NaiveDice.Tickets.Batches
  alias NaiveDice.Repo
  require Logger

  def run(email, token, user, event) do
    with  {:ok, ^user} <- user |> Accounts.check_email(email),
          false <- user |> Tickets.has_ticket(event),
          false <- event |> Tickets.is_sold_out,
          %Reservation{status: :active} = reservation <- user |> Tickets.get_reservation,
          {:ok, _result} <- user |> Batches.create_payment(event, reservation, token) |> Repo.transaction do

            reservation
            |> Tickets.cancel_expiry_task
            |> case do
              {:ok, :cancelled} -> {:ok, :payment_success}
              {:error, error} ->
                Logger.error(inspect error)
                {:ok, :payment_success}
            end
    else
      {:error, _step, _reason, _results} ->
        {:payment_failed, "The payment was unsuccessful, please try again"}
      error -> error
    end
  end
end