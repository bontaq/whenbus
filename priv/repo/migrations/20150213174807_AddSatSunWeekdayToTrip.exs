defmodule Whenbus.Repo.Migrations.AddSatSunWeekdayToTrip do
  use Ecto.Migration

  def up do
    alter table(:trips) do
      add :weekday, :boolean, default: false
      add :saturday, :boolean, default: false
      add :sunday, :boolean, default: false
    end
  end

  def down do
    alter table(:trips) do
      remove :weekday
      remove :saturday
      remove :sunday
    end
  end
end
