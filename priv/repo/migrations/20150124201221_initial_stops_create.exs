defmodule Whenbus.Repo.Migrations.InitialStopsCreate do
  use Ecto.Migration

  def up do
    create table(:stops) do
      add :name, :string, size: 255
      add :stopId, :string, size: 255
      add :latitude, :float
      add :longitude, :float
    end
  end

  def down do
    drop table(:stops)
  end
end
