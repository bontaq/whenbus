defmodule Whenbus.Repo.Migrations.TripsAddDayTypeRemoveWeekdaySatSun do
  use Ecto.Migration

  def up do
    alter table(:trips) do
      remove :weekday
      remove :saturday
      remove :sunday
      add :day_type, :integer
    end
  end

  def down do
    alter table(:trips) do
      remove :day_type
      add :weekday, :boolean, default: false
      add :saturday, :boolean, default: false
      add :sunday, :boolean, default: false
    end
  end
end
