defmodule Whenbus.Repo.Migrations.AddStopTimes do
  use Ecto.Migration

  def up do
    create table(:stop_times) do
      add :tripId, :string, size: 255
      add :departureTime, :time
      add :stopId, :string, size: 255
      add :stopSequence, :string, size: 255
    end
  end

  def down do
    drop table(:stop_times)
  end
end
