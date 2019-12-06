defmodule NaiveDice.Repo.Migrations.AddNumberSoldToEvents do
  use Ecto.Migration

  def change do
  	alter table(:events) do
      add :number_sold, :integer, default: 0
    end
  end
end
