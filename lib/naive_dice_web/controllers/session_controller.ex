defmodule NaiveDiceWeb.SessionController do
  use NaiveDiceWeb, :controller
  alias NaiveDiceWeb.Endpoint
  alias NaiveDice.Tickets


  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"username" => user, "password" => password}}) do
    case NaiveDice.Auth.authenticate_user(user, password) do
      {:ok, user} ->
        conn
        |> NaiveDice.Auth.login(user)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.reservation_path(Endpoint, :new))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, params) do
    params |> expire_users_active_reservation
    conn
    |> NaiveDice.Auth.logout()
    |> redirect(to: Routes.page_path(Endpoint, :index))
  end

  def expire_users_active_reservation(%{"id" => id}) do
    _reservation = id |> Tickets.expire_users_active_reservation
  end
end