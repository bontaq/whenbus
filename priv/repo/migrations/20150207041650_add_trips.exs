defmodule Whenbus.Repo.Migrations.AddTrips do
  use Ecto.Migration

  def up do
    create table(:trips) do
      add :route, :string, size: 255
      add :service_id, :string, size: 255
      add :trip_id, :string, size: 255
      add :headsign, :string, size: 255
      add :direction, :integer
    end
  end

  def down do
    drop table(:trips)
  end
end
