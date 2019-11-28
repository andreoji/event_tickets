defmodule NaiveDiceWeb.PaymentController do
  use NaiveDiceWeb, :controller
  alias NaiveDiceWeb.Endpoint
  require Logger
  
  @stripe_api Application.get_env(:naive_dice, :stripe_api)
  
  def new(conn, _params) do
   	render(conn, "_payment.html")
  end
  
  def create(conn, params = %{"stripeEmail" => _email, "stripeToken" => token}) do
   	with {:ok, charge = %Stripe.Charge{}} <- @stripe_api.create_charge(1999, "USD", token) do
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