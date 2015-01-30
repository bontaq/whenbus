defmodule Whenbus.ApiController do
  use Phoenix.Controller

  import Ecto.Query, only: [from: 2]

  plug :action

  def search_stops(name) do
    regex_name = name
      |> String.replace(" ", "%")
      |> (&("%#{&1}%")).()

    query = from s in Whenbus.Stop,
      where: ilike(s.name, ^regex_name),
      select: s

    Whenbus.Repo.all(query)
  end

  def find(conn, %{"name" => name}) do
    results = search_stops(name)
    json(conn, results)
  end

  def find(conn, _) do
    text(conn, "That's no good")
  end
end
