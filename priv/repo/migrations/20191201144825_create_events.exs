defmodule NaiveDice.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :capacity, :integer
      add :price, :integer
      add :currency, :string, size: 3

      timestamps()
    end

    create unique_index(:events, [:title])
  end
end
