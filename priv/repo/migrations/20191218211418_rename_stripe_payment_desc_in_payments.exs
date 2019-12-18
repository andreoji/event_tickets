defmodule NaiveDice.Repo.Migrations.RenameStripePaymentDescInPayments do
  use Ecto.Migration

  def change do
	rename table(:payments), :stripe_payment_desc, to: :stripe_payment_id 
  end
end
