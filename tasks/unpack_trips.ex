defmodule Mix.Tasks.Whenbus.Load_trips do
  import Ecto.Query, only: [from: 2]
  use Mix.Task

  @shortdoc "Load trip information from trips.txt"

  @moduledoc """
  Load every trip from trips.txt into the DB, as Whenbus.Trip
  """
  # route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id
  def build_trip([route_id, service_id, trip_id, headsign, direction, _, _]) do
    unless route_id == "route_id" do
      {parsed_direction, _} = Integer.parse(direction)
      %Whenbus.Trip
      { route: route_id,
        serviceId: service_id,
        tripId: trip_id,
        tripHeadsign: headsign,
        direction: parsed_direction }
    else
      :error
    end
  end
  def build_trip(_) do
    :error
  end

  def exists(trip) do
    query = from s in Whenbus.Trip, where: s.serviceId == ^trip.serviceId
    (length Whenbus.Repo.all(query)) >= 1
  end

  def run(_) do
    Whenbus.Repo.start_link()

    File.stream!("route_data/trips.txt")
    |> Enum.map(fn(x) -> String.split(x, ",") end)
    |> Enum.map(fn(row) -> build_trip(row) end)  # create objects
    |> Enum.filter(fn(row) -> row != :error end)  # remove errors
    |> Enum.filter(fn(trip) -> not exists(trip) end)  # check not already in DB
    |> Enum.map(fn(trip) -> Whenbus.Repo.insert trip end) # insert rows
  end
end
