defmodule Mix.Tasks.LoadStops do
  import Whenbus.Repo
  import Whenbus.Stop
  use Mix.Task

  @shortdoc "Load stop information from stops.txt"

  @moduledoc """
  Load every stop from stops.txt into the DB, as Whenbus.Stop
  """
  defmodule StopBuild do
    def build_stop([id, _, name, _, lat, lon, _]) do
      {float_lat, _} = Float.parse(String.strip(lat))
      {float_lon, _} = Float.parse(String.strip(lon))
      %Whenbus.Stop{
                  name: name,
                  stopId: id,
                  latitude: float_lat,
                  longitude: float_lon
              }
    end
    def build_stop(_) do [] end
  end

  def run(_) do
    Whenbus.Repo.start_link()

    File.read!("route_data/stops.txt")
    |> String.split("\n")
    |> Enum.drop(1)  # drop header
    |> Enum.map(&(String.split(&1, ",")))  # split on line commas
    |> Enum.map(fn(row) -> StopBuild.build_stop(row) end)
    |> Enum.map(fn(stop) -> Whenbus.Repo.insert stop end) # insert rows
  end
end
