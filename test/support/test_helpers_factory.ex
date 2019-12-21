defmodule NaiveDiceWeb.TestHelpers.Factory do
  alias NaiveDice.Repo
  alias NaiveDice.Accounts.User
  alias NaiveDice.Tickets.Event

  @event_title Application.get_env(:naive_dice, :event_title)

  @event %{
  	title: @event_title,
  	capacity: 5,
  	price: 1999,
  	currency: "USD",
  	event_status: "active",
    number_sold: 0
  }

  def insert_event do
    %Event{}
    |> Event.create_changeset(@event)
    |> Repo.insert!()
  end

  @default_user %{name: "john lennon", username: "johnl", password: "j123l", email: "john@acme.com"}

  def insert_user(attrs \\ %{}) do
    changes =
      attrs
      |> case do
        %{} -> @default_user
        attrs -> attrs 
      end

    %User{}
    |> User.create_changeset(changes)
    |> Repo.insert!()
  end
end