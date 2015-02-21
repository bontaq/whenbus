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

  def str_time_to_tuple(tuple) do
    tuple
    |> Enum.map(fn(x) -> Integer.parse(x) end)
    |> Enum.map(fn(x) -> elem(x, 0) end)
    |> List.to_tuple
  end

  def one_day_ago(date) do
    date
    |> :calendar.date_to_gregorian_days
    |> (&(&1 - 1)).()
    |> :calendar.gregorian_days_to_date
  end

  def adjust_day_for_after_midnight(date, time) do
    case time do
      {hour, _, _} when hour < 4 -> one_day_ago(date)
      _ -> date
    end
  end

  def which_day(date, time) do
    day_of_week = date
    |> adjust_day_for_after_midnight(time)
    |> :calendar.day_of_the_week

    case day_of_week do
      7 -> :sunday
      6 -> :saturday
      _ -> :weekday
    end
  end

  def search_stop_times(stop_id, %{"date" => date, "time" => time}) do
    {hour, minute, second} = time
    future_time = {rem((hour + 1), 24), minute, second}

    day_type = case which_day(date, time) do
      :weekday -> 0
      :sunday -> 2
      :saturday -> 1
      _ -> 0
    end

    query = from s in Whenbus.StopTime,
      join: t in Whenbus.Trip, on: t.trip_id == s.trip_id,
      where: ^stop_id == s.stop_id
        and s.departure_time > ^time
        and s.departure_time < ^future_time
        and t.day_type == ^day_type,
      select: s,
      order_by: s.departure_time,
      preload: :trip

    Whenbus.Repo.all(query)
  end

  def stop_times(conn, %{"stopId" => stop_id, "time" => date_time}) do
    parsed_time = for {key, val} <- date_time, into: %{}, do: {key, str_time_to_tuple(val)}
    adjusted_date = parsed_time["date"]
    |> (fn({y, m, d}) -> {y, (m + 1), d} end).() # JS months start from 0, erlang from 1
    final_date_time = %{parsed_time | "date" => adjusted_date}

    results = search_stop_times(stop_id, final_date_time)
    |> Enum.map(fn(x) -> %{x | departure_time: Tuple.to_list(x.departure_time)} end)
    # Turn departure time into tuple because Poison can't encode it as is

    json(conn, results)
  end
  def stop_times(conn, _) do
    text(conn, "That's no good - from find stop times")
  end
end
