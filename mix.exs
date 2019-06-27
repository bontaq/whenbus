defmodule Whenbus.Mixfile do
  use Mix.Project

  def project do
    [app: :whenbus,
     version: "0.0.1",
     elixir: "~> 1.8.1",
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
    [{:phoenix, "~> 1.4.8"},
     {:phoenix_html, ">= 0.0.0"},
     {:cowboy, ">= 1.0.0"},
     {:plug_cowboy, ">= 0.0.0"},
     {:ecto_sql, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:poison, "4.0.1"},
     {:ecto, "3.1.6"}]
  end
end
