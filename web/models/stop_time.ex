defmodule Whenbus.StopTime do
  use Ecto.Model

  schema "stop_times" do
    field :tripId, :string
    field :departureTime, :time
    field :stopId, :string
    field :stopSequence, :string
  end
end
