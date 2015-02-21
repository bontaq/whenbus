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
           stop_id: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert

    res = Whenbus.ApiController.search_stops("Wharton")
    [stop | _] = res
    assert stop.name == "5TH & WHARTON"
    assert stop.stop_id == "10"
    assert stop.latitude == 5.5
    assert stop.longitude == 4.5
  end

  test "Find stop inserted, no match" do
    %Stop {name: "5TH & WHARTON",
           stop_id: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert

    res = Whenbus.ApiController.search_stops("Zbk")
    assert res == []
  end

  test "Find stop, with spaces" do
    %Stop {name: "5TH & WHARTON",
           stop_id: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert

    res = Whenbus.ApiController.search_stops("5 whar")
    assert length(res) == 1
    [stop | _] = res
    assert stop.stop_id == "10"
  end

  test "Find stop, multiple stops, with flip search" do
    %Stop {name: "5TH & WHARTON",
           stop_id: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert
    %Stop {name: "WHARTON & 5TH",
           stop_id: "11",
           latitude: 5.0,
           longitude: 4.0}
    |> Repo.insert
    res = Whenbus.ApiController.search_stops("5 whar")
    assert length(res) == 2
    [stopA, stopB] = res
    assert stopA.stop_id == "10"
    assert stopB.stop_id == "11"
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
    %Trip {
            route: "0",
            service_id: "1",
            trip_id: "1",
            headsign: "3",
            direction: 0,
            day_type: 0
        }
    |> Repo.insert
    %StopTime{
            trip_id: "1",
            departure_time: {10, 10, 10},
            stop_id: "2",
            stop_sequence: "3"
        }
    |> Repo.insert
    res = Whenbus.ApiController.search_stop_times(
      "2",
      %{"date" => {2015, 1, 16}, "time" => {10, 9, 0}}
    )
    assert (length res) > 0
  end

  test "Return JSON stoptime" do
    %Trip {
            route: "0",
            service_id: "1",
            trip_id: "1",
            headsign: "3",
            direction: 0,
            day_type: 0
        }
    |> Repo.insert
    %StopTime{
            trip_id: "1",
            departure_time: {10, 10, 10},
            stop_id: "2",
            stop_sequence: "3"
        }
    |> Repo.insert
    conn = call(Whenbus.Router, :get, "api/stoptimes?stopId=2&time%5Bdate%5D%5B%5D=2015&time%5Bdate%5D%5B%5D=1&time%5Bdate%5D%5B%5D=16&time%5Btime%5D%5B%5D=10&time%5Btime%5D%5B%5D=9&time%5Btime%5D%5B%5D=0")
    [res] = Poison.decode! conn.resp_body
    assert res["trip"]["route"] == "0"
    assert res["trip"]["headsign"] == "3"
    assert res["stop_id"] == "2"
    assert res["trip_id"] == "1"
  end

  test "Get stop name" do
    %Trip{
            route: "0",
            service_id: "1",
            trip_id: "2",
            headsign: "3",
            direction: 0,
        }
    |> Repo.insert
    %{:route => route, :service_id => service_id} = Whenbus.ApiController.get_trip("2")
    assert route == "0"
    assert service_id == "1"
  end

  test "Get bus times with time" do
    %Trip {
            route: "0",
            service_id: "1",
            trip_id: "1",
            headsign: "3",
            direction: 0,
            day_type: 0
        }
    |> Repo.insert
    %StopTime{
            trip_id: "1",
            departure_time: {10, 10, 0},
            stop_id: "2",
            stop_sequence: "3"
        }
    |> Repo.insert
    %StopTime{
            trip_id: "1",
            departure_time: {11, 10, 0},
            stop_id: "2",
            stop_sequence: "3"
        }
    |> Repo.insert

    res = Whenbus.ApiController.search_stop_times(
      "2",
      %{"date" => {2015, 1, 16}, "time" => {10, 9, 0}}
    )
    assert length(res) == 1
  end

  test "trip is associated with stop_time" do
    %Trip {
            route: "0",
            service_id: "1",
            trip_id: "1",
            headsign: "3",
            direction: 0,
            day_type: 0
        }
    |> Repo.insert
    %StopTime{
            trip_id: "1",
            departure_time: {10, 10, 0},
            stop_id: "2",
            stop_sequence: "3"
        }
    |> Repo.insert
    [res] = Whenbus.ApiController.search_stop_times(
      "2",
      %{"date" => {2015, 1, 16}, "time" => {10, 9, 0}}
    )
    assert res.trip.route == "0"
  end

  test "one_day_ago" do
    res = Whenbus.ApiController.one_day_ago({2015, 1, 10})
    assert res == {2015, 1, 9}
    border = Whenbus.ApiController.one_day_ago({2015, 1, 1})
    assert border == {2014, 12, 31}
  end

  test "which_day returns weekday for weekday" do
    res = Whenbus.ApiController.which_day({2015, 2, 18}, {10, 10, 10})
    assert res == :weekday
  end

  test "which_day returns sunday for sunday" do
    res = Whenbus.ApiController.which_day({2015, 2, 15}, {10, 10, 10})
    assert res == :sunday
  end

  test "which_day returns saturday for saturday" do
    res = Whenbus.ApiController.which_day({2015, 2, 14}, {10, 10, 10})
    assert res == :saturday
  end

  test "which_day after midnight saturday" do
    res = Whenbus.ApiController.which_day({2015, 2, 14}, {1, 10, 0})
    assert res == :weekday
  end

  test "wich_day after midnight monday" do
    res = Whenbus.ApiController.which_day({2015, 2, 16}, {1, 10, 0})
    assert res == :sunday
  end

  test "time out of range error" do
    # future_time was going over 24 hours
    %{"date" => ["2015", "1", "20"], "time" => ["23", "18", "0"]}
    [] = Whenbus.ApiController.search_stop_times(
      "2",
      %{"date" => {2015, 1, 20}, "time" => {23, 18, 0}}
    )
  end
end
