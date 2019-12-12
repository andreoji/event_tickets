defmodule NaiveDice.Tickets.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reservations" do
    field :status, StatusEnum
    field :event_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def create_changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
