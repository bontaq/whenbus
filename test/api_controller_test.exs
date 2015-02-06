defmodule Whenbus.ApiControllerTest do
  use ExUnit.Case, async: false

  import Plug.Test

  alias Whenbus.Stop
  alias Whenbus.Repo

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
    assert conn.resp_body == "That's no good"
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
    %Stop {name: "5th & Wharton",
           stopId: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert

    res = Whenbus.ApiController.search_stops("Wharton")
    [stop | _] = res
    assert stop.name == "5th & Wharton"
    assert stop.stopId == "10"
    assert stop.latitude == 5.5
    assert stop.longitude == 4.5
  end

  test "Find stop inserted, no match" do
    %Stop {name: "5th & Wharton",
           stopId: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert

    res = Whenbus.ApiController.search_stops("Zbk")
    assert res == []
  end

  test "Find stop, with spaces" do
    %Stop {name: "5th & Wharton",
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
    %Stop {name: "5th & Wharton",
           stopId: "10",
           latitude: 5.5,
           longitude: 4.5}
    |> Repo.insert
    %Stop {name: "Wharton & 5th",
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
end
