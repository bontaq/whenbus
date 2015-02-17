defmodule Whenbus.Repo.Migrations.AddStopTimes do
  use Ecto.Migration

  def up do
    create table(:stop_times) do
      add :trip_id, :string, size: 255
      add :departure_time, :time
      add :stop_id, :string, size: 255
      add :stop_sequence, :string, size: 255
    end
  end

  def down do
    drop table(:stop_times)
  end
end
