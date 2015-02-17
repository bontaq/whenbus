defmodule Whenbus.StopTime do
  use Ecto.Model

  schema "stop_times" do
    field :trip_id, :string
    field :departure_time, :time
    field :stop_id, :string
    field :stop_sequence, :string
  end
end
