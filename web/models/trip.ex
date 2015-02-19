defmodule Whenbus.Trip do
  use Ecto.Model

  schema "trips" do
    field :route, :string
    field :service_id, :string
    field :trip_id, :string
    field :headsign, :string
    field :direction, :integer
    field :day_type, :integer   # 0: weekday, 1: saturday, 2: sunday
  end
end
