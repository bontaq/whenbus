defmodule Whenbus.ApiController do
  use Phoenix.Controller

  import Ecto.Query, only: [from: 2]

  plug :action

  def search_stops(name) do
    regex_name = String.upcase(name)
      |> String.split(" ")
      |> (&(&1 ++ ["|"] ++ Enum.reverse(&1))).()
      |> Enum.join(".*")

    query = from s in Whenbus.Stop,
      where: fragment("name ~ ?", ^regex_name),
      select: s

    Whenbus.Repo.all(query)
  end

  def find(conn, %{"name" => name}) do
    results = search_stops(name)
    json(conn, results)
  end
  def find(conn, _) do
    text(conn, "That's no good - from find stops")
  end

  def get_trip(trip_id) do
    Whenbus.Repo.one from t in Whenbus.Trip, where: t.trip_id == ^trip_id
  end

  def search_stop_times(stop_id, %{"date" => date, "time" => time}) do
    parsedTime = Enum.map(time, fn(x) -> Integer.parse(x) end)
      |> Enum.map(fn(x) -> elem(x, 0) end)
      |> List.to_tuple
    {hour, minute, second} = parsedTime
    futureTime = {(hour + 1), minute, second}

    query = from s in Whenbus.StopTime,
      where: ^stop_id == s.stop_id
        and s.departure_time > ^parsedTime
        and s.departure_time < ^futureTime,
      select: s,
      order_by: s.departure_time,
      preload: :trip

    Whenbus.Repo.all(query)
  end

  def stop_times(conn, %{"stopId" => stop_id, "time" => time}) do
    results = search_stop_times(stop_id, time)
    |> Enum.map(fn(x) -> %{x | departure_time: Tuple.to_list(x.departure_time)} end)
    # Turn departure time into tuple because Poison can't encode it as is

    json(conn, results)
  end
  def stop_times(conn, _) do
    text(conn, "That's no good - from find stop times")
  end
end
