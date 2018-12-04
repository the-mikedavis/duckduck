defmodule DuckDuck.MixProject do
  use Mix.Project

  def project do
    [
      app: :duck_duck,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.4"}
    ]
  end
end
