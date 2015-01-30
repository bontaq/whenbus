Code.require_file("http_client.exs", __DIR__)

defmodule Whenbus.IntegrationTest do
  use ExUnit.Case
  # alias Whenbus.Integration.HTTPClient

  # test "toplevel route matches new action" do
  #   conn = call(Router, :get, "account/new")
  #   assert conn.status == 200
  #   assert conn.resp_body == "new account"
  # end

  # Glorious failing test

  # test "let's see" do
  #   {:ok, resp} = HTTPClient.request(:get, "http://127.0.0.1", %{})
  #   IO.puts resp
  # end
end
