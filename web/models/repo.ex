defmodule Whenbus.Repo do
  use Ecto.Repo,
    otp_app: :whenbus,
    adapter: Ecto.Adapters.Postgres
end
