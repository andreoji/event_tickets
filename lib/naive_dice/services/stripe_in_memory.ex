defmodule NaiveDice.Services.Stripe.InMemory do

  def create_charge(amount, currency, token), do: do_create_charge(amount, currency, token)
	
  def do_create_charge(1999, "USD", :ok), do: {:ok, %{id: "ch_1FqHamHCCcwyjBBXsipQMPMT"}}
  def do_create_charge(1999, "USD", :stripe_error), do: {:stripe_error, "The payment was unsuccessful, please try again"}
end