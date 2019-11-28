defmodule NaiveDiceWeb.ReservationController do
  use NaiveDiceWeb, :controller
  alias NaiveDice.Repo

  def new(conn, _params) do
    render(conn, "_reservation.html")
  end

  def create(conn, _params) do
    render(conn, "index.html")
  end
end