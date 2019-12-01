defmodule NaiveDice.Tickets do
  @moduledoc """
  The Tickets context.
  """
  require Logger

  import Ecto.Query, warn: false

  alias NaiveDice.Repo
  alias NaiveDice.Tickets.Reservation

  def create_reservation(user) do
    change_set =
      %Reservation{user_id: user.id, event_id: 1} 
        |> Reservation.create_changeset(%{status: :active})
    
      case Repo.insert(change_set) do
        {:ok, reservation} -> {:ok, reservation}
        {:error, error} -> 
          Logger.error(inspect error)
          {:error, "Reservation unsuccessful"}
      end
  end

  def active_reservation?(user) do
    query = from r in Reservation, where: r.user_id == ^user.id and
                                          r.status == "active"
    case Repo.exists?(query)  do
      false -> false
      true -> {:active_reservation, "You have a current reservation, proceed with payment"}
    end
  end
end