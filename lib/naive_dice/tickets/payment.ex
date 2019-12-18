defmodule NaiveDice.Tickets.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :stripe_payment_id, :string
    field :user_id, :id
    field :event_id, :id

    timestamps()
  end

  @doc false
  def create_changeset(payment, attrs) do
    payment
    |> cast(attrs, [:stripe_payment_id])
    |> validate_required([:stripe_payment_id])
    |> unique_constraint(:stripe_payment_id)
  end
end
