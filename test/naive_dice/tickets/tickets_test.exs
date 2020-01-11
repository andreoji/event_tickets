defmodule NaiveDice.Tickets.Test do
  use NaiveDice.DataCase
  import Ecto.Query, warn: false
  alias NaiveDice.Tickets
  alias NaiveDice.Tickets.Reservation

  describe "upsert_reservation/1 when there's no existing reservation" do
    setup [:create_event, :create_user]

    test "creates a new active reservation", %{
      user: user
    } do
      
      assert {:ok, %Reservation{status: :active}} = user |> Tickets.upsert_reservation
    end
  end

  describe "upsert_reservation/1 when there's an existing expired reservation" do
    setup [:create_event, :create_user_with_expired_reservation]

    test "updates the reservation to active", %{
      user: user,
      reservation: reservation
    } do
      status_before = reservation.status
      assert status_before == :expired

      user |> Tickets.upsert_reservation

      reservation = reservation |> reload_reservation
      assert reservation.status == :active
    end
  end

  describe "is_reservation_active/1 when the reservation is expired" do
    setup [:create_event, :create_user_with_expired_reservation]

    test "returns false", %{
      user: user
    } do

      refute user |> Tickets.is_reservation_active
    end
  end

  describe "is_reservation_active/1 when the reservation is active" do
    setup [:create_event, :create_user, :already_reserved]

    test "returns the active tuple", %{
      user: user
    } do
      
      assert {:active, error} = user |> Tickets.is_reservation_active
    end
  end

  describe "get_reservation/1 when the reservation is active" do
    setup [:create_event, :create_user, :already_reserved]

    test "returns the active reservation", %{
      user: user
    } do

      assert %Reservation{status: :active} = user |> Tickets.get_reservation
    end
  end

  describe "get_reservation/1 when the reservation is expired" do
    setup [:create_event, :create_user_with_expired_reservation]

    test "returns the expired", %{
      user: user
    } do
      
      assert %Reservation{status: :expired} = user |> Tickets.get_reservation
    end
  end

  describe "get_reservation/1 when the user has no reservation" do
    setup [:create_event, :create_user]

    test "returns the no reservation tuple", %{
      user: user
    } do
      
      assert {:no_reservation, error} = user |> Tickets.get_reservation
    end
  end

  describe "active_event/0 when there is an active event" do
    setup [:create_event]

    test "returns the active event tuple", %{
      event: event
    } do

      assert {:ok, ^event} = Tickets.active_event
    end
  end

  describe "active_event/0 when there is no active event" do
    test "returns an error", %{
    } do

      assert {:error, "There is no active event"} = Tickets.active_event
    end
  end

  describe "set_reservation_expiry/1" do
    setup [:create_event, :create_user, :already_reserved]

    test "expires an active reservation after the expiry interval", %{
      reservation: reservation
    } do
      status_before = reservation.status
      assert status_before == :active

      {:ok, _auto_id} = reservation |> Tickets.set_reservation_expiry
      reservation = reservation |> wait_for_expiry
      assert reservation.status == :expired
    end
  end

  describe "expire_users_active_reservation/1 when user id exists" do
    setup [:create_event, :create_user, :already_reserved]

    test "sets the reservation to expired", %{
      user: user,
      reservation: reservation
    } do
      status_before = reservation.status
      assert status_before == :active

      # id will be a string in reality
      user.id |> Integer.to_string |> Tickets.expire_users_active_reservation
      reservation = reservation |> reload_reservation
      assert reservation.status == :expired
    end
  end

  describe "expire_users_active_reservation/1 when the id doesn't exist" do
    setup [:create_event, :create_user, :already_reserved]

    test "returns a noop", %{
      user: _user
    } do

      assert :noop = "-1" |> Tickets.expire_users_active_reservation
    end
  end

  describe "is_sold_out/1 when the event isn't sold out" do
    setup [:create_event]

    test "returns false", %{
      event: event
    } do

      refute event |> Tickets.is_sold_out
    end
  end

  describe "is_sold_out/1 when the event is sold out" do
    setup [:create_event, :sell_event_out]

    test "returns the sold out tuple", %{
      event: event
    } do

      assert {:sold_out, "Sorry The Sound of Music is now sold out"} = event |> Tickets.is_sold_out
    end
  end

  describe "has_ticket/2 when payment has already been completed" do
    setup [:create_event, :create_user_with_completed_payment]
    test "returns the has ticket tuple", %{
      user: user,
      event: event
    } do

      assert {:has_ticket, "You have a ticket already"} = user |> Tickets.has_ticket(event)
    end
  end

  describe "has_ticket/2 without a completed payment" do
    setup [:create_event, :create_user, :already_reserved]
    test "returns false", %{
      user: user,
      event: event
    } do

      refute user |> Tickets.has_ticket(event)
    end
  end
end