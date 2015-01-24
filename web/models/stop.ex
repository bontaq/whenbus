defmodule Whenbus.Stop do
  use Ecto.Model

  schema "stops" do
    field :name, :string
    field :stopId, :string
    field :latitude, :float
    field :longitude, :float
  end
end
