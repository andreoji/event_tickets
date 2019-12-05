defmodule NaiveDice.Tickets.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias NaiveDice.Tickets.{Payment, Reservation}

  schema "events" do
    field :capacity, :integer
    field :currency, :string
    field :price, :integer
    field :status, EventStatusEnum
    field :title, :string
    has_many :payments, Payment
    has_many :reservations, Reservation
    
    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :status, :capacity, :price, :currency])
    |> validate_required([:title, :status, :capacity, :price, :currency])
    |> validate_length(:currency, is: 3)
    |> unique_constraint(:title)
  end
end
