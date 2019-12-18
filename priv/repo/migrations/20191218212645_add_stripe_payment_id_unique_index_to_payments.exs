defmodule NaiveDice.Repo.Migrations.AddStripePaymentIdUniqueIndexToPayments do
  use Ecto.Migration

  def change do
  	create unique_index(:payments, [:stripe_payment_id])
  end
end
