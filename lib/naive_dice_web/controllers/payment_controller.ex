defmodule NaiveDiceWeb.PaymentController do
  use NaiveDiceWeb, :controller
  alias NaiveDiceWeb.Endpoint
  require Logger
  alias NaiveDice.Tickets.Reservation
  alias NaiveDice.Tickets.Payment.Workflow, as: PaymentWorkflow
  alias NaiveDiceWeb.Endpoint
  import NaiveDice.Auth, only: [load_current_user: 2]
  import NaiveDice.Tickets, only: [load_event: 2]
  plug(:load_current_user)
  plug(:load_event)


  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user, conn.assigns.event])
  end
  
  def new(conn, _params, _user, _event) do
   	render(conn, "_payment.html")
  end
  
  def create(conn, %{"stripeEmail" => email, "stripeToken" => token}, user, event) do
    PaymentWorkflow.run(email, token, user, event)
    |>
    case do
      {:ok, :payment_success} ->
        conn
        |> put_flash(:info, "Payment successful")
        |> render("_congratulations.html")
      {:payment_failed, error} ->
        conn
        |> put_flash(:error, error)
        |> render("_payment.html")
      {:sold_out, error} ->
        conn
        |> put_flash(:error, error)
        |> render("_payment.html")
      %Reservation{status: :expired} ->
        conn
        |> put_flash(:error, "You reservation has expired, enter name again")
        |> redirect(to: Routes.reservation_path(Endpoint, :new))
      {:has_ticket, error} ->
        conn
        |> put_flash(:error, error)
        |> render("_payment.html")
      {:no_reservation, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.reservation_path(Endpoint, :new))
      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> render("_payment.html")
    end
  end
end