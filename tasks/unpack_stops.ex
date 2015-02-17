defmodule Mix.Tasks.Whenbus.Load_stops do
  import Ecto.Query, only: [from: 2]
  use Mix.Task

  @shortdoc "Load stop information from stops.txt"

  @moduledoc """
  Load every stop from stops.txt into the DB, as Whenbus.Stop
  """
  def build_stop([id, _, name, _, lat, lon, _]) do
    parse = fn(x) -> Float.parse(String.strip(x)) end
    case parse.(lat) do
      :error -> :error
      {f_lat, _} -> %Whenbus.Stop
                  { name: String.upcase(name),
                    stop_id: id,
                    latitude: f_lat,
                    longitude: parse.(lon) |> elem 0 }
    end
  end

  def exists(stop) do
    query = from s in Whenbus.Stop, where: s.stop_id == ^stop.stop_id
    (length Whenbus.Repo.all(query)) >= 1
  end

  def run(_) do
    Whenbus.Repo.start_link()

    File.stream!("route_data/stops.txt")
    |> Enum.map(fn(x) -> String.split(x, ",") end)
    |> Enum.map(fn(row) -> build_stop(row) end)  # create objects
    |> Enum.filter(fn(row) -> row != :error end)  # remove errors
    |> Enum.filter(fn(stop) -> not exists(stop) end)  # check not already in DB
    |> Enum.map(fn(stop) -> Whenbus.Repo.insert stop end) # insert rows
  end
end
