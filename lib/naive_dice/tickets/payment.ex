defmodule NaiveDice.Tickets.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :stripe_payment_desc, :string
    field :user_id, :id
    field :event_id, :id

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:stripe_payment_desc])
    |> validate_required([:stripe_payment_desc])
  end
end
