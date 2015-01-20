defmodule Whenbus.Endpoint do
  use Phoenix.Endpoint, otp_app: :whenbus

  plug Plug.Static,
    at: "/", from: :whenbus

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_whenbus_key",
    signing_salt: "WyWXWAqX",
    encryption_salt: "OUqdaALk"

  plug :router, Whenbus.Router
end
