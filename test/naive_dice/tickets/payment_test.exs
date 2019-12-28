defmodule NaiveDice.Tickets.PaymentTest do
  use NaiveDice.DataCase
  import NaiveDiceWeb.Factory
  import Ecto.Query, warn: false
  alias NaiveDice.Tickets.Payment
  alias NaiveDice.Tickets.Batches

  describe "create_changeset/2" do
    setup [:create_event, :create_user_with_completed_payment]

    test "returns an error when stripe_payment_id is non-unique", %{
      event: event,
      payment: payment
    } do
      u = insert(:user)
      {:error, changeset} = 
        %Payment{event_id: event.id, user_id: u.id}
        |> Payment.create_changeset(%{stripe_payment_id: payment.stripe_payment_id})
        |> Repo.insert
     
      assert %{stripe_payment_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "create a payment with a unique stripe_payment_id", %{
      event: event
    } do
      u = insert(:user)
      gen_id = Batches.generate_random_string()
      {:ok, %Payment{stripe_payment_id: stripe_payment_id}} = 
        %Payment{event_id: event.id, user_id: u.id}
        |> Payment.create_changeset(%{stripe_payment_id: gen_id})
        |> Repo.insert
     
      assert stripe_payment_id == gen_id
    end
  end
end