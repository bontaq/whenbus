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

  def search_stop_times(stop_id, time) do
    query = from s in Whenbus.StopTime,
      where: ^stop_id == s.stopId,
      select: s
    Whenbus.Repo.all(query)
  end

  def stop_times(conn, %{"stopId" => stop_id, "time" => time}) do
    results = search_stop_times(stop_id, time)
      |> Enum.map(fn(x) -> %{x | departureTime: Tuple.to_list(x.departureTime)} end)
    json(conn, results)
  end

  def stop_times(conn, _) do
    text(conn, "That's no good - from find stop times")
  end
end
