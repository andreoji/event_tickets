defmodule NaiveDice.Repo.Migrations.AddStatusToEvents do
  use Ecto.Migration
  
  def change do
  	EventStatusEnum.create_type
  	alter table(:events) do
      add :event_status, EventStatusEnum.type()
    end
  end
end
