defmodule NaiveDice.Tickets do
  @moduledoc """
  The Tickets context.
  """
  require Logger

  import Ecto.Query, warn: false
  import Plug.Conn

  @event_title Application.get_env(:naive_dice, :event_title)
  @expiry_interval Application.get_env(:naive_dice, :expiry_interval)

  alias NaiveDice.Repo
  alias NaiveDice.Tickets
  alias NaiveDice.Tickets.{Event, Payment, Reservation}
  alias NaiveDice.Accounts.User

  def load_event(conn, _) do
    conn
    |> assign(:event, from(e in Event, where: e.title == @event_title) |> Repo.one)
  end

  def upsert_reservation(user) do
    with {:ok, event} <- Tickets.active_event,
         {status, reservation} <- user |> Tickets.reservation_status,
         {:ok, reservation} <- event |> do_upsert_reservation(user, {status, reservation}) do
      {:ok, reservation}
    else
      {:error, error} -> 
        Logger.error(inspect error)
        {:error, "Reservation unsuccessful"}
    end 
  end

  defp do_upsert_reservation(event, user, {:no_reservation, _error}) do
    with reservation <- %Reservation{user_id: user.id, event_id: event.id} |> Reservation.create_changeset(%{status: :active}),
      {:ok, reservation} <- reservation |> Repo.insert do
      {:ok, reservation}
    else
      error -> error
    end
  end

  defp do_upsert_reservation(_event, _user, {:expired, reservation}) do
    with reservation <- reservation |> Ecto.Changeset.change(status: :active),
      {:ok, reservation} <- reservation |> Repo.update do
      {:ok, reservation}
    else
      error -> error
    end
  end

  def is_reservation_active(user) do
    from(r in Reservation,
      where:  r.user_id == ^user.id and
              r.status == "active"
    )
    |> Repo.exists?
    |> case do
      false -> false
      true -> {:active, "You have a current reservation, proceed with payment"}
    end
  end

  def reservation_status(user)  do
    Repo.get_by(Reservation, user_id: user.id)
    |> case do
        nil -> {:no_reservation, "You don't have a current reservation, proceed with reservation first"}
        reservation -> {reservation.status, reservation}
    end
  end

  def active_event  do
    from(e in Event, where: e.event_status == "active")
    |> Repo.one
    |> case do
        nil -> {:error, "There is no active event"}
        event -> {:ok, event}
    end
  end
  
  def set_reservation_expiry(reservation) do
    with {:ok, auto_id} <- @expiry_interval |> TaskAfter.task_after((fn -> reservation |> expire_active_reservation end)),
      :ok <- auto_id |> NaiveDice.Teardown.ExpiryTasks.add_task do
      {:ok, auto_id}
    else 
      error ->
        Logger.error(inspect error)
        {:error, "Oops! Something went wrong"}
    end
  end

  defp expire_active_reservation(reservation) do
    reservation = Repo.get(Reservation, reservation.id)
    if (reservation.status == :active) do
      reservation = reservation |> Ecto.Changeset.change(status: :expired)
      reservation |> Repo.update
    end
  end

  def expire_users_active_reservation(id) do
    _reservation =
      from(r in Reservation,
       where: r.status == "active" and
              r.user_id == ^id
      )
      |> Repo.one
      |> case do
          nil -> :noop
          reservation ->
            reservation = reservation |> Ecto.Changeset.change(status: :expired)
            reservation |> Repo.update
      end
  end

  def create_payment(charge, user, event, reservation) do
    with payment <- %Payment{user_id: user.id, event_id: event.id} |> Payment.create_changeset(%{stripe_payment_desc: charge.id}),
      {:ok, payment} <- payment |> Repo.insert,
      {:ok, _reservation} <- reservation |> set_reservation_to_completed,
      {1, nil} <- event |> increment_number_sold,
      {:ok, _} <- event |>  set_event_to_sold_out do
      {:ok, payment}
    else
      error ->
        Logger.error(inspect error)
        {:error, "Oops! Something went wrong"}
    end
  end

  defp set_reservation_to_completed(reservation) do
    %Reservation{id: reservation.id}
      |> Ecto.Changeset.change(status: :completed)
      |> Repo.update
  end

  defp increment_number_sold(event) do
    from(e in Event,
      update: [inc: [number_sold: 1]],
      where: e.id == ^event.id
    )
    |> Repo.update_all([])
  end

  defp set_event_to_sold_out(event) do
    event =
      event = Repo.get(Event, event.id)
      (event.number_sold == event.capacity)
      |> case do
          true ->
            event = event |> Ecto.Changeset.change(event_status: :sold_out)
            event |> Repo.update
          false -> {:ok, :not_sold_out}
      end
  end

  def is_sold_out(event) do
    event = Repo.get(Event, event.id)
      cond do
        event.event_status == :sold_out ->
          {:sold_out, "Sorry #{event.title} is now sold out"}
        true -> false
      end
  end

  def has_ticket(user, event) do
    from(p in Payment,
      where:  p.user_id == ^user.id and
      p.event_id == ^event.id
    )
    |> Repo.exists?
    |> case do
        false -> false
        true -> {:has_ticket, "You have a ticket already"}
    end
  end

  def guests(event) do
    from(u in User,
      join: p in Payment,
      on: u.id == p.user_id,
    where: p.event_id == ^event.id,
    select: u.name
    )
    |> Repo.all
  end
end