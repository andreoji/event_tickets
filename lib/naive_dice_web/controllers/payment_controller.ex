defmodule NaiveDiceWeb.PaymentController do
  use NaiveDiceWeb, :controller
  alias NaiveDiceWeb.Endpoint
  require Logger
  @stripe_api Application.get_env(:naive_dice, :stripe_api)
  alias NaiveDiceWeb.Endpoint
  import NaiveDice.Auth, only: [load_current_user: 2]

  plug(:load_current_user)

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end
  
  
  def new(conn, _params, _user) do
   	render(conn, "_payment.html")
  end
  
  def create(conn, _params = %{"stripeEmail" => _email, "stripeToken" => token}, _user) do
    # validate enter email is the same as the current users email
   	with {:ok, _charge = %Stripe.Charge{}} <- @stripe_api.create_charge(1999, "USD", token) do
   	  conn
   	  	|> put_flash(:info, "Payment successful")
   	  	|> redirect(to: Routes.reservation_path(Endpoint, :new))	  
   	else
	    error ->
		    Logger.error(inspect error)
	      conn
	       |> put_flash(:info, "Payment unsuccessful")
	       |> redirect(to: Routes.reservation_path(Endpoint, :new))
   	end
  end
end