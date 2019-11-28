defmodule NaiveDice.Services.Stripe.Api do
  require Stripe

  def create_charge(amount, currency, token) do
    case Stripe.Charge.create(%{amount: amount, currency: currency, source: token}) do
        {:ok, charge = %Stripe.Charge{}} -> {:ok, charge}
        error -> error
    end
  end
end