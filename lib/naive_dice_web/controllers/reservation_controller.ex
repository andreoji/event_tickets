defmodule NaiveDiceWeb.ReservationController do
  use NaiveDiceWeb, :controller
  alias NaiveDiceWeb.Endpoint
  alias NaiveDice.{Accounts, Tickets}
  import NaiveDice.Auth, only: [load_current_user: 2]
  import NaiveDice.Tickets, only: [load_event: 2]
  plug(:load_current_user)
  plug(:load_event)

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user, conn.assigns.event])
  end
  
  def new(conn, _params, _user, _event) do
    render(conn, "_reservation.html")
  end

  def create(conn, %{"name" => name}, user, event) do
    with  {:ok, ^user} <- user |> Accounts.check_name(name),
          false <- user |> Tickets.has_ticket(event),
          false <- event |> Tickets.is_sold_out,
          false <- user |> Tickets.is_reservation_active,
          {:ok, reservation} <- user |> Tickets.upsert_reservation,
          {:ok, _auto_id} <- reservation |> Tickets.set_reservation_expiry do
      conn
        |> put_flash(:info, "Reservation successful" )
        |> redirect(to: Routes.payment_path(Endpoint, :new))
    else
      {:sold_out, error} ->
        conn
        |> put_flash(:error, error)
        |> render("_reservation.html")
      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> render("_reservation.html")
      {:active, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.payment_path(Endpoint, :new))
      {:has_ticket, error} ->
        conn
        |> put_flash(:error, error)
        |> render("_reservation.html")
    end
  end
end