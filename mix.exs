defmodule Whenbus.Mixfile do
  use Mix.Project

  def project do
    [app: :whenbus,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web", "tasks"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Whenbus, []},
     applications: [:phoenix, :cowboy, :logger, :postgrex, :ecto]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.8.0"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.7.0"},
     {:ecto, "0.7.2"}]
  end
end
