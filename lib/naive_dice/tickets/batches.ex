defmodule NaiveDice.Tickets.Batches do

  import Ecto.Query
  import Ecto.Query, warn: false
  require Logger
  alias Ecto.Multi
  alias NaiveDice.Tickets.{Event, Payment, Reservation}
  @stripe_api Application.get_env(:naive_dice, :stripe_api)


  def create_payment(user, event, reservation, token) do

    insert_payment = fn repo, _ ->
      %Payment{event_id: event.id, user_id: user.id}
      |> Payment.create_changeset(%{stripe_payment_id: generate_random_string()})
      |> repo.insert
    end

    set_reservation_to_completed  = fn repo, %{insert_payment_step: _payment} ->
      %Reservation{id: reservation.id, event_id: event.id, user_id: user.id}
      |> Ecto.Changeset.change(status: :completed)
      |> repo.update
    end

    increment_number_sold = fn repo, %{set_reservation_to_completed_step: _reservation} ->
      from(e in Event,
        where: e.id == ^event.id,
        lock: "FOR UPDATE"
      )
      |> repo.one
      |> Ecto.Changeset.change(number_sold: event.number_sold + 1)
      |> repo.update
    end

    set_event_to_sold_out = fn repo, %{increment_number_sold_step: event} ->
      event =
        event = from(e in Event,
          where: e.id == ^event.id,
          lock: "FOR UPDATE"
        )
        |> repo.one
        (event.number_sold == event.capacity)
        |> case do
            true ->
              event = event |> Ecto.Changeset.change(event_status: :sold_out)
              event |> repo.update
              {:ok, :sold_out}
            false -> {:ok, :not_sold_out}
        end
    end

    create_stripe_charge = fn _repo, %{set_event_to_sold_out_step: _} ->
      #returns {:ok, charge} or {:error, error}
      @stripe_api.create_charge(event.price, event.currency, token)
    end

    update_payment_with_stripe_id = fn repo, %{create_stripe_charge_step: stripe_charge} ->
      from(p in Payment,
          where: p.user_id == ^user.id
      )
      |> repo.one
      |> Payment.create_changeset(%{stripe_payment_id: stripe_charge.id})
      |> repo.update
    end

    Multi.new()
    |> Multi.run(:insert_payment_step, insert_payment)
    |> Multi.run(:set_reservation_to_completed_step, set_reservation_to_completed)
    |> Multi.run(:increment_number_sold_step, increment_number_sold)
    |> Multi.run(:set_event_to_sold_out_step, set_event_to_sold_out)
    |> Multi.run(:create_stripe_charge_step, create_stripe_charge)
    |> Multi.run(:update_payment_with_stripe_id_step, update_payment_with_stripe_id)
  end

  def generate_random_string do
    alphabet = Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)
    length = 12
    for _ <- 1..length, into: "", do: << Enum.random(alphabet) >>
  end
end