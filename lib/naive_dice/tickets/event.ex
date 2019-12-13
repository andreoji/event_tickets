defmodule NaiveDice.Tickets.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias NaiveDice.Tickets.{Payment, Reservation}

  schema "events" do
    field :capacity, :integer
    field :currency, :string
    field :price, :integer
    field :number_sold, :integer
    field :event_status, EventStatusEnum
    field :title, :string
    has_many :payments, Payment
    has_many :reservations, Reservation
    
    timestamps()
  end

  @doc false
  def create_changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :event_status, :capacity, :price, :currency])
    |> validate_required([:title, :event_status, :capacity, :price, :currency])
    |> validate_length(:currency, is: 3)
    |> unique_constraint(:title)
  end
end
