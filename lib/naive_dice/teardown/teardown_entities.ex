defmodule NaiveDice.Teardown.Entities do
  @moduledoc """
  The Teardown context. Only needed for testing purposes.
  """

  require Logger

  import Ecto.Query, warn: false

  alias NaiveDice.Repo
  alias NaiveDice.Tickets.{Event, Payment, Reservation}

  def rip_it_up_and_start_again(event) do
    with  {_r_count, nil} <- from(r in Reservation, where: r.event_id == ^event.id) |> Repo.delete_all,
      {_p_count, nil} <- from(p in Payment, where: p.event_id == ^event.id) |> Repo.delete_all,
      {:ok, _event} <- event |> set_event_defaults
    do
      :successful_teardown
    else
      error -> {:unsuccessful_teardown, error}
    end
  end

  defp set_event_defaults(event) do
    %Event{id: event.id}
      |> Ecto.Changeset.change(event_status: :active, number_sold: 0)
      |> Repo.update
  end
end