defmodule NaiveDiceWeb.ReservationController do
  use NaiveDiceWeb, :controller
  alias NaiveDiceWeb.Endpoint
  alias NaiveDice.Tickets
  alias NaiveDice.Accounts
  import NaiveDice.Auth, only: [load_current_user: 2]

  plug(:load_current_user)

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end
  
  def new(conn, _params, _user) do
    render(conn, "_reservation.html")
  end

  def create(conn, %{"name" => name}, user) do
    with {:ok, ^user} <- name |> Accounts.check_name,
         false <- user |> Tickets.active_reservation?,
         {:ok, reservation} <- user |> Tickets.create_reservation,
         :ok <- reservation |> Tickets.set_reservation_expiry do
      conn
        |> put_flash(:info, "Reservation successful" )
        |> redirect(to: Routes.payment_path(Endpoint, :new))
    else
      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> render("_reservation.html")

      {:active_reservation, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.payment_path(Endpoint, :new))
    end 
  end
end