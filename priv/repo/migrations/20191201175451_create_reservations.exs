defmodule NaiveDice.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    StatusEnum.create_type
    create table(:reservations) do
      add :status, StatusEnum.type()
      add :event_id, references(:events, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:reservations, [:event_id])
    create index(:reservations, [:user_id])
    create unique_index(:reservations, [:user_id, :event_id])
  end
end
