defmodule NaiveDiceWeb.PaymentController do
  use NaiveDiceWeb, :controller
  alias NaiveDiceWeb.Endpoint
  require Logger
  @stripe_api Application.get_env(:naive_dice, :stripe_api)
  alias NaiveDice.{Accounts, Tickets}
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
    with false <- user |> Tickets.has_ticket?(event),
      {:active, reservation} <- user |> Tickets.reservation_status,
      {:ok, ^user} <- user |> Accounts.check_email(email),
      false <- event |> Tickets.sold_out?,
      {:ok, charge = %Stripe.Charge{}} <- @stripe_api.create_charge(event.price, event.currency, token),
      {:ok, _payment} <- charge |> Tickets.create_payment(user, event, reservation) do
      conn
        |> put_flash(:info, "Payment successful")
        |> render("_congratulations.html")
    else
      {:sold_out, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.payment_path(Endpoint, :new))

      {:expired, _reservation} ->
        conn
         |> put_flash(:error, "You reservation has expired, enter name again")
         |> redirect(to: Routes.reservation_path(Endpoint, :new))
      {:error, error} = e ->
        Logger.error(inspect e)
        conn
         |> put_flash(:info, error)
         |> redirect(to: Routes.reservation_path(Endpoint, :new))
      {:has_ticket, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.payment_path(Endpoint, :new))
    end
  end
end