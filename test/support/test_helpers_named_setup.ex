defmodule NaiveDiceWeb.TestHelpers.NamedSetup do
  import Ecto.Query, warn: false
  import NaiveDiceWeb.Factory
  alias NaiveDice.Tickets.{Event, Reservation}
  alias NaiveDice.Repo

  # helpers shared between reservation and payment controllers
  def log_user_in(context), do: do_log_user_in(context)

  def do_log_user_in(%{conn: conn, event: _event, user: user, post_session_fun: post_session_fun} = context) do
    conn = post_session_fun.(user, conn)
    context |> Map.merge(%{conn: conn, params: %{"name" => user.name}})
  end

  def do_log_user_in(%{conn: conn, event: _event, post_session_fun: post_session_fun} = context) do
    user = insert(:user)
    conn = post_session_fun.(user, conn)
    context |> Map.merge(%{conn: conn, params: %{"name" => user.name}, user: user})
  end
  
  def create_event(context) do
    event = insert(:event)
    context |> Map.merge(%{event: event})
  end

  def create_sold_out_event(context) do
    event = insert(:event, event_status: :sold_out, number_sold: 5)
    context |> Map.merge(%{event: event})
  end

  def sell_event_out(%{event: event} = context) do
    {:ok, event} = 
      %Event{id: event.id}
        |> Ecto.Changeset.change(event_status: :sold_out, number_sold: 5)
        |> Repo.update
    %{context | event: event}
  end

  def reload_event(event), do: Repo.get(Event, event.id)
  def reload_reservation(reservation), do: Repo.get(Reservation, reservation.id)

  # reservation controller only helpers
  def already_reserved(%{event: event, user: user} = context) do
    insert(:reservation, event_id: event.id, user_id: user.id)
    context
  end

  def create_user_with_expired_reservation(%{event: event} = context) do
    user = insert(:user)
    reservation = insert(:reservation, event_id: event.id, user_id: user.id, status: :expired)
    context |> Map.merge(%{user: user, reservation: reservation})
  end

  def create_an_expired_reservation(%{event: event, user: user} = context) do
    reservation = insert(:reservation, event_id: event.id, user_id: user.id, status: :expired)
    context |> Map.merge(%{reservation: reservation})
  end

  def reservation_count(query), do: Repo.one(from(r in query, select: count(r.id)))

  #payment controller only helpers
  def create_reservation(%{event: event, user: user} = context) do
    reservation = insert(:reservation, event_id: event.id, user_id: user.id)
    context |> Map.merge(%{reservation: reservation})
  end

  def create_expired_reservation(%{event: event, user: user} = context) do
    reservation = insert(:reservation, event_id: event.id, user_id: user.id, status: :expired)
    context |> Map.merge(%{reservation: reservation})
  end

  def create_user_with_completed_payment(%{event: event} = context) do
    user = insert(:user)
    reservation = insert(:reservation, event_id: event.id, user_id: user.id, status: :completed)
    payment = insert(:payment, event_id: event.id, user_id: user.id)
    context |> Map.merge(%{user: user, reservation: reservation, payment: payment})
  end

  def payment_count(query), do: Repo.one(from(p in query, select: count(p.id)))
end