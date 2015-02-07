defmodule Whenbus.Trip do
  use Ecto.Model

  schema "trips" do
    field :route, :string
    field :serviceId, :string
    field :tripId, :string
    field :tripHeadsign, :string
    field :direction, :integer
  end
end
