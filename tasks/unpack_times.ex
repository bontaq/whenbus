defmodule Mix.Tasks.Whenbus.Load_times do
  import Ecto.Query, only: [from: 2]
  use Mix.Task

  @shortdoc "Load stop information from stop_times.txt"

  @moduledoc """
  Load every stop from stop_times.txt into the DB, as Whenbus.StopTime
  """
  def build_stop_time([trip_id, _, depart_time, stop_id, stop_seq, _, _]) do
    unless depart_time == "departure_time" do
      # "10:15:20" -> {10, 15, 20}
      parsed_time = depart_time
      |> String.split(":")
      |> Enum.map(fn(x) -> Integer.parse(x) end)
      |> Enum.map(fn(x) -> elem(x, 0) end)
      |> List.to_tuple

      # Pat uses times > 24 to represent routes that run past midnight
      if elem(parsed_time, 0) >= 24 do
        {hour, min, sec} = parsed_time
        parsed_time = {(hour - 24), min, sec}
      end

      %Whenbus.StopTime
      { tripId: trip_id,
        departureTime: parsed_time,
        stopId: stop_id,
        stopSequence: stop_seq }
    else
      :error
    end
  end

  def exists(stop) do
    query = from s in Whenbus.StopTime, where: s.stopSequence == ^stop.stopSequence
    (length Whenbus.Repo.all(query)) >= 1
  end

  def run(_) do
    Whenbus.Repo.start_link()

    File.stream!("route_data/stop_times.txt")
    |> Enum.map(fn(x) -> String.split(x, ",") end)
    |> Enum.map(fn(row) -> build_stop_time(row) end)  # create objects
    |> Enum.filter(fn(row) -> row != :error end)  # remove errors
    |> Enum.filter(fn(stop) -> not exists(stop) end)  # check not already in DB
    |> Enum.map(fn(stop) -> Whenbus.Repo.insert stop end) # insert rows
  end
end
