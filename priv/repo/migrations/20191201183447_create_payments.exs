defmodule NaiveDice.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :stripe_payment_desc, :string, null: false
      add :event_id, references(:events, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:payments, [:event_id])
    create index(:payments, [:user_id])
    create unique_index(:payments, [:user_id, :event_id])
  end
end
