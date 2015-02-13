defmodule Whenbus.ApiControllerTest do
  use ExUnit.Case, async: false

  import Plug.Test

  alias Whenbus.Repo
  alias Whenbus.Stop
  alias Whenbus.StopTime
  alias Whenbus.Trip

  # reset DB after each test
  setup do
    Ecto.Adapters.SQL.begin_test_transaction(Repo)

    on_exit fn ->
      Ecto.Adapters.SQL.rollback_test_transaction(Repo)
    end

    :ok
  end

  def call(router, verb, path, params \\ nil, headers \\ []) do
    conn = conn(verb, path, params, headers) |> Plug.Conn.fetch_params
    router.call(conn, router.init([]))
  end

  test "Bad find request" do
    conn = call(Whenbus.Router, :get, "api/find?b=b")
    assert conn.resp_body == "That's no good - from find stops"
  end

  test "Good find request, no stops inserted" do
    conn = call(Whenbus.Router, :get, "api/find?name=test")
    assert conn.resp_body == "[]"
  end

  # test "Good find request, stop inserted" do
  #   %Whenbus.Stop {}
  #   |> Whenbus.Repo.insert
  # end

  test "Find with stop inserted" do
    %Stop {name: "5TH & WHARTON",
           stopId: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert

    res = Whenbus.ApiController.search_stops("Wharton")
    [stop | _] = res
    assert stop.name == "5TH & WHARTON"
    assert stop.stopId == "10"
    assert stop.latitude == 5.5
    assert stop.longitude == 4.5
  end

  test "Find stop inserted, no match" do
    %Stop {name: "5TH & WHARTON",
           stopId: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert

    res = Whenbus.ApiController.search_stops("Zbk")
    assert res == []
  end

  test "Find stop, with spaces" do
    %Stop {name: "5TH & WHARTON",
           stopId: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert

    res = Whenbus.ApiController.search_stops("5 whar")
    assert length(res) == 1
    [stop | _] = res
    assert stop.stopId == "10"
  end

  test "Find stop, multiple stops, with flip search" do
    %Stop {name: "5TH & WHARTON",
           stopId: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert
    %Stop {name: "WHARTON & 5TH",
           stopId: "11",
           latitude: 5.0,
           longitude: 4.0}
    |> Repo.insert
    res = Whenbus.ApiController.search_stops("5 whar")
    assert length(res) == 2
    [stopA, stopB] = res
    assert stopA.stopId == "10"
  end

  # test "Too short find request" do
  # end

  # test "Find request (no spaces)" do
  # end

  # test "Find request (1 spaces)" do
  # end

  # test "Find request (2 spaces)" do
  # end

  # test "Find via lat / lon" do
  #   # to be implemented
  # end

  test "Return stops from stop id and time" do
    %StopTime{
            tripId: "1",
            departureTime: {10, 10, 10},
            stopId: "2",
            stopSequence: "3"
        }
    |> Repo.insert
    res = Whenbus.ApiController.search_stop_times("2", 1)
    assert (length res) > 0
  end

  test "Return JSON stoptime" do
    %StopTime{
            tripId: "1",
            departureTime: {10, 10, 10},
            stopId: "2",
            stopSequence: "3"
        }
    |> Repo.insert
    %Trip {
            route: "0",
            serviceId: "1",
            tripId: "1",
            tripHeadsign: "3",
            direction: 0
        }
    |> Repo.insert
    conn = call(Whenbus.Router, :get, "api/stoptimes?stopId=2&time=test")

    [%{"stop" => stop, "trip" => trip}] = Poison.decode! conn.resp_body
    assert trip["route"] == "0"
    assert trip["tripHeadsign"] == "3"
    assert stop["tripId"] == "1"
    assert stop["stopId"] == "2"
  end

  test "Get stop name" do
    %Trip{
            route: "0",
            serviceId: "1",
            tripId: "2",
            tripHeadsign: "3",
            direction: 0,
        }
    |> Repo.insert
    %{:route => route, :serviceId => serviceId} = Whenbus.ApiController.get_trip("2")
    assert route == "0"
    assert serviceId == "1"
  end
end
