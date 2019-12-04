defmodule NaiveDice.Tickets do
  @moduledoc """
  The Tickets context.
  """
  require Logger

  import Ecto.Query, warn: false

  alias NaiveDice.Repo
  alias NaiveDice.Tickets.Reservation

  @interval 300_000

  def create_reservation(user) do
    %Reservation{user_id: user.id, event_id: 1} 
      |> Reservation.create_changeset(%{status: :active})
      |> Repo.insert
      |> case do
          {:ok, reservation} -> {:ok, reservation}
          {:error, error} -> 
            Logger.error(inspect error)
            {:error, "Reservation unsuccessful"}
      end
  end

  def active_reservation?(user) do
    case active_reservation_query(user) |> Repo.exists? do
      false -> false
      true -> {:active_reservation, "You have a current reservation, proceed with payment"}
    end
  end

  def set_reservation_expiry(reservation) do
    reservation = reservation |> Ecto.Changeset.change(status: :expired)
    with {:ok, _auto_id} <- TaskAfter.task_after(@interval, fn -> reservation |> Repo.update end) do
      :ok
    else
      error ->
        Logger.error(inspect error)
        {:error, "Oops! Something went wrong"}
    end
  end

  defp active_reservation_query(user)  do
    from r in Reservation, where: r.user_id == ^user.id and
                                  r.status == "active"
  end
end