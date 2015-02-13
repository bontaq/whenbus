defmodule Whenbus.Trip do
  use Ecto.Model

  schema "trips" do
    field :route, :string
    field :serviceId, :string
    field :tripId, :string
    field :tripHeadsign, :string
    field :direction, :integer
    field :weekday, :boolean, default: false
    field :saturday, :boolean, default: false
    field :sunday, :boolean, default: false
  end
end
