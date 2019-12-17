defmodule NaiveDiceWeb.ReservationControllerTest do
  use NaiveDiceWeb.ConnCase
  import Ecto.Query, warn: false
  alias NaiveDice.Tickets.Reservation

  describe "create/4" do
    setup [:create_event, :log_user_in]
    test "responds with a success message and creates a new reservation", %{
      conn: conn,
      params: params,
    } do
      count_before = reservation_count(Reservation)
      conn = post(conn, Routes.reservation_path(conn, :create), params)

      assert reservation_count(Reservation) == (count_before + 1)
      assert redirected_to(conn) == Routes.payment_path(conn, :new)
      assert get_flash(conn, :info) == "Reservation successful"
    end

    test "responds with an error message when a reservation is posted for a second time", %{
      conn: conn,
      params: params,
    } do
      conn = post(conn, Routes.reservation_path(conn, :create), params)

      count_before = reservation_count(Reservation)
      conn = post(conn, Routes.reservation_path(conn, :create), params)

      assert reservation_count(Reservation) == count_before
      assert redirected_to(conn) == Routes.payment_path(conn, :new)
      assert get_flash(conn, :error) == "You have a current reservation, proceed with payment"
    end

    test "responds with an error message when the full name is incorrect", %{
      conn: conn,
      params: params,
    } do
      count_before = reservation_count(Reservation)
      conn = post(conn, Routes.reservation_path(conn, :create), %{params| "name" => "jane doe"})

      assert reservation_count(Reservation) == count_before
      assert get_flash(conn, :error) == "The full name entered doesn't match"
    end
  end

  describe "create/4 when already reserved" do
    setup [:create_event, :log_user_in, :already_reserved]
    test "responds with a success message and creates a new reservation", %{
      conn: conn,
      params: params,
    } do
      count_before = reservation_count(Reservation)
      conn = post(conn, Routes.reservation_path(conn, :create), params)

      assert reservation_count(Reservation) == count_before
      assert redirected_to(conn) == Routes.payment_path(conn, :new)
      assert get_flash(conn, :error) == "You have a current reservation, proceed with payment"
    end
  end

  describe "create/4 when the event sells out" do
    setup [:create_event, :log_user_in, :sell_event_out]
    test "responds with a sold out error message and no new payment", %{
      conn: conn,
      event: event,
      params: params
    } do
      event = event |> reload_event
      count_before = reservation_count(Reservation)

      conn = post(conn, Routes.reservation_path(conn, :create), params)

      assert reservation_count(Reservation) == count_before
      assert get_flash(conn, :error) == "Sorry #{event.title} is now sold out"
      assert response(conn, 200) =~ "DON'T MISS YOUR TICKETS"
    end
  end

  describe "create/4 when already reserved but expired" do
    setup [:create_event, :log_user_in, :create_an_expired_reservation]
    test "responds with a success message and resets the expired reservation to active", %{
      conn: conn,
      params: params,
      reservation: reservation
    } do
      count_before = reservation_count(Reservation)
      conn = post(conn, Routes.reservation_path(conn, :create), params)

      assert reservation_count(Reservation) == count_before
      assert redirected_to(conn) == Routes.payment_path(conn, :new)
      assert get_flash(conn, :info) == "Reservation successful"
      reservation = reservation |> reload_reservation

      assert reservation.status == :active
    end
  end

  describe "create/4 when user has an existing expired reservation on login" do
    setup [:create_event, :create_user_with_expired_reservation, :log_user_in]
    test "responds with a success message and resets the expired reservation to active", %{
      conn: conn,
      params: params,
      reservation: reservation
    } do
      count_before = reservation_count(Reservation)
      conn = post(conn, Routes.reservation_path(conn, :create), params)

      assert reservation_count(Reservation) == count_before
      assert redirected_to(conn) == Routes.payment_path(conn, :new)
      assert get_flash(conn, :info) == "Reservation successful"
      reservation = reservation |> reload_reservation

      assert reservation.status == :active
    end
  end

  describe "create/4 when event is sold out" do
    setup [:create_sold_out_event, :log_user_in]
    test "responds with an error message the event is sold out", %{
      conn: conn,
      params: params,
      event: event
    } do
      count_before = reservation_count(Reservation)
      conn = post(conn, Routes.reservation_path(conn, :create), params)

      assert reservation_count(Reservation) == count_before
      assert get_flash(conn, :error) == "Sorry #{event.title} is now sold out"
    end
  end
end