defmodule NaiveDiceWeb.ReservationController do
  use NaiveDiceWeb, :controller
  alias NaiveDiceWeb.Endpoint

  import NaiveDice.Auth, only: [load_current_user: 2]

  plug(:load_current_user)

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end
  
  def new(conn, _params, _user) do
    render(conn, "_reservation.html")
  end

  def create(conn, _params, _user) do
  	redirect(conn, to: Routes.payment_path(Endpoint, :new))
  end
end