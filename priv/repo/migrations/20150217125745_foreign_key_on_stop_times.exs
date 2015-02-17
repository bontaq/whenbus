defmodule Whenbus.Repo.Migrations.ForeignKeyOnStopTimes do
  use Ecto.Migration

  def up do
    create index(:trips, [:trip_id], unique: true)

    alter table(:stop_times) do
      remove :trip_id
      add :trip_id, references(:trips, [{:column, :trip_id}, {:type, :string}])
    end
  end

  def down do
    alter table(:stop_times) do
      remove :trip_id
      add :trip_id, :string, size: 255
    end
  end
end
