defmodule NaiveDice.Tickets.Payment.Workflow do
  @stripe_api Application.get_env(:naive_dice, :stripe_api)
  alias NaiveDice.{Accounts, Tickets}

  def run(email, token, user, event) do
    with  {:ok, ^user} <- user |> Accounts.check_email(email),
          false <- user |> Tickets.has_ticket(event),
          false <- event |> Tickets.is_sold_out,
          {:active, reservation} <- user |> Tickets.reservation_status,
          {:ok, charge} <- @stripe_api.create_charge(event.price, event.currency, token) do
            {:ok, _payment} = charge |> Tickets.create_payment(user, event, reservation)
    end
  end
end