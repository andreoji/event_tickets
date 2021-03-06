defmodule NaiveDiceWeb.PaymentControllerTest do
  use NaiveDiceWeb.ConnCase
  import Ecto.Query, warn: false
  alias NaiveDice.Tickets.Payment

  describe "create/4 when reservation is active" do
    setup [:create_event, :log_user_in, :create_reservation]
    test "responds with a success message and creates a new payment", %{
      conn: conn,
      user: user,
      reservation: reservation
    } do
      count_before = payment_count(Payment)
      conn = post(conn, Routes.payment_path(conn, :create), %{"stripeEmail" => user.email, "stripeToken" => :ok})

      assert get_flash(conn, :info) == "Payment successful"
      assert payment_count(Payment) == (count_before + 1)
      reservation = reservation |> reload_reservation
      assert reservation.status == :completed
    end
  end

  describe "create/4 when the email is incorrect" do
    setup [:create_event, :log_user_in, :create_reservation]
    test "responds with an email error message and no new payment", %{
      conn: conn,
      user: _user,
      reservation: reservation
    } do
      count_before = payment_count(Payment)
      conn = post(conn, Routes.payment_path(conn, :create), %{"stripeEmail" => "janed@1acme.com", "stripeToken" => :ok})

      assert get_flash(conn, :error) == "The email entered doesn't match"
      assert payment_count(Payment) == (count_before)
      reservation = reservation |> reload_reservation
      assert reservation.status == :active
    end
  end

  describe "create/4 when reservation has expired" do
    setup [:create_event, :log_user_in, :create_expired_reservation]
    test "responds with an expiry error message and no new payment", %{
      conn: conn,
      user: user
    } do
      count_before = payment_count(Payment)
      conn = post(conn, Routes.payment_path(conn, :create), %{"stripeEmail" => user.email, "stripeToken" => :ok})

      assert payment_count(Payment) == count_before
      assert get_flash(conn, :error) == "You reservation has expired, enter name again"
      assert redirected_to(conn) == Routes.reservation_path(conn, :new)
    end
  end

  describe "create/4 when payment has already been completed" do
    setup [:create_event, :create_user_with_completed_payment, :log_user_in]
    test "responds with a ticket already error message and no new payment", %{
      conn: conn,
      user: user
    } do
      count_before = payment_count(Payment)
      conn = post(conn, Routes.payment_path(conn, :create), %{"stripeEmail" => user.email, "stripeToken" => :ok})

      assert payment_count(Payment) == count_before
      assert get_flash(conn, :error) == "You have a ticket already"
      assert response(conn, 200) =~ "Nice to meet you #{user.name}"
    end
  end

  describe "create/4 when the event sells out" do
    setup [:create_event, :log_user_in, :create_reservation, :sell_event_out]
    test "responds with a sold out error message and no new payment", %{
      conn: conn,
      user: user,
      event: event
    } do
      event = event |> reload_event
      count_before = payment_count(Payment)

      conn = post(conn, Routes.payment_path(conn, :create), %{"stripeEmail" => user.email, "stripeToken" => :ok})

      assert payment_count(Payment) == count_before
      assert get_flash(conn, :error) == "Sorry #{event.title} is now sold out"
      assert response(conn, 200) =~ "Nice to meet you #{user.name}"
    end
  end

  describe "create/4 when the stripe api call fails" do
    setup [:create_event, :log_user_in, :create_reservation]
    test "responds with a payment unsuccessful error message and no new payment", %{
      conn: conn,
      user: user,
      reservation: reservation
    } do
      count_before = payment_count(Payment)

      conn = post(conn, Routes.payment_path(conn, :create), %{"stripeEmail" => user.email, "stripeToken" => :error})

      assert payment_count(Payment) == count_before
      assert get_flash(conn, :error) == "The payment was unsuccessful, please try again"
      assert response(conn, 200) =~ "Nice to meet you #{user.name}"
      reservation = reservation |> reload_reservation
      assert reservation.status == :active
    end
  end
end