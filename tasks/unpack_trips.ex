defmodule Mix.Tasks.Whenbus.Load_trips do
  import Ecto.Query, only: [from: 2]
  use Mix.Task

  @shortdoc "Load trip information from trips.txt"

  @moduledoc """
  Load every trip from trips.txt into the DB, as Whenbus.Trip
  """
  def build_trip([route_id, service_id, trip_id, headsign, direction, _, _]) do
    unless route_id == "route_id" do
      {parsed_direction, _} = Integer.parse(direction)
      [parsed_route, _] = route_id
        |> String.lstrip(?0)
        |> String.split("-")

      weekday = String.contains?(service_id, "Weekday")
      saturday = String.contains?(service_id, "Saturday")
      sunday = String.contains?(service_id, "Sunday")

      %Whenbus.Trip
      { route: parsed_route,
        service_id: service_id,
        trip_id: trip_id,
        headsign: headsign,
        direction: parsed_direction,
        weekday: weekday,
        saturday: saturday,
        sunday: sunday}
    else
      :error
    end
  end
  def build_trip(_) do
    :error
  end

  def exists(trip) do
    query = from s in Whenbus.Trip, where: s.service_id == ^trip.service_id
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
