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
    text(conn, "That's no good")
  end
end
