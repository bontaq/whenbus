defmodule Whenbus.Stop do
  use Ecto.Schema

  schema "stops" do
    field :name, :string
    field :stop_id, :string
    field :latitude, :float
    field :longitude, :float
  end
end
