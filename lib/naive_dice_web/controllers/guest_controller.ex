defmodule NaiveDiceWeb.GuestController do
  use NaiveDiceWeb, :controller
  require Logger
  alias NaiveDiceWeb.Endpoint
  alias NaiveDice.Tickets
  alias NaiveDice.Teardown.Entities
  import NaiveDice.Auth, only: [load_current_user: 2]
  import NaiveDice.Tickets, only: [load_event: 2]
  plug(:load_current_user)
  plug(:load_event)


  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user, conn.assigns.event])
  end

  def index(conn, _params, _user, event) do
  	guests = event |> Tickets.guests
    render(conn, "index.html", guests: guests)
  end

  def create(conn, _params, _user, event) do
    with  :successful_teardown <- event |> Entities.rip_it_up_and_start_again,
          {:ok, :cancelled} <- NaiveDice.Teardown.ExpiryTasks.cancel_all do
      conn
      |> put_flash(:info, "Successful teardown")
      |> redirect(to: Routes.reservation_path(Endpoint, :new))
    else
      {:unsuccessful_teardown, _error} = e ->
        Logger.error(inspect e)
        conn
        |> put_flash(:error, "The teardown may have errored")
        |> render("index.html", guests: [])
      
      error -> Logger.error(inspect error)
        conn
        |> put_flash(:error, "The teardown may have errored")
        |> render("index.html", guests: [])
    end
  end
end