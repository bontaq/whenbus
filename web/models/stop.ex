defmodule Whenbus.Stop do
  use Ecto.Model

  schema "stops" do
    field :name, :string
    field :stop_id, :string
    field :latitude, :float
    field :longitude, :float
  end
end
