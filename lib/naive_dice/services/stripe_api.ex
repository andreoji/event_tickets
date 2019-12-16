defmodule NaiveDice.Services.Stripe.Api do
  require Stripe
  require Logger

  def create_charge(amount, currency, token) do
    case Stripe.Charge.create(%{amount: amount, currency: currency, source: token}) do
        {:ok, charge} -> {:ok, charge}
        {:error, error} ->
          Logger.error(inspect error)
          {:stripe_error, "The payment was unsuccessful, please try again"}
    end
  end
end