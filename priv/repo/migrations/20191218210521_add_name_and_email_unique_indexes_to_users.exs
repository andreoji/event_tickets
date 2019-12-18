defmodule NaiveDice.Repo.Migrations.AddNameAndEmailUniqueIndexesToUsers do
  use Ecto.Migration

  def change do
  	create unique_index(:users, [:name])
  	create unique_index(:users, [:email])
  end
end
