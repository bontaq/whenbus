defmodule Whenbus.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end

  scope "/", Whenbus do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Whenbus do
    pipe_through :api

    get "/find", ApiController, :find
    get "/stoptimes", ApiController, :stop_times
  end
end
