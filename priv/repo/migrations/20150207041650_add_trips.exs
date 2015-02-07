defmodule Whenbus.Repo.Migrations.AddTrips do
  use Ecto.Migration

  def up do
    create table(:trips) do
      add :route, :string, size: 255
      add :serviceId, :string, size: 255
      add :tripId, :string, size: 255
      add :tripHeadsign, :string, size: 255
      add :direction, :integer
    end
  end

  def down do
    drop table(:trips)
  end
end
