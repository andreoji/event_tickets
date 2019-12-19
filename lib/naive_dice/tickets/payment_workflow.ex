defmodule NaiveDice.Tickets.Payment.Workflow do
  @stripe_api Application.get_env(:naive_dice, :stripe_api)
  alias NaiveDice.{Accounts, Tickets}
  alias NaiveDice.Tickets.Reservation
  require Logger

  def run(email, token, user, event) do
    with  {:ok, ^user} <- user |> Accounts.check_email(email),
          false <- user |> Tickets.has_ticket(event),
          false <- event |> Tickets.is_sold_out,
          %Reservation{status: :active} = reservation <- user |> Tickets.get_reservation,
          {:ok, charge} <- @stripe_api.create_charge(event.price, event.currency, token),
          {:ok, payment} <- charge |> Tickets.create_payment(user, event, reservation) do
            reservation
            |> Tickets.cancel_expiry_task
            |> case do
              {:ok, :cancelled} -> {:ok, payment}
              {:error, error} ->
                Logger.error(inspect error)
                {:ok, payment}
            end
    end
  end
end