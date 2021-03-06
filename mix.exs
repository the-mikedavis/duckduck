defmodule DuckDuck.MixProject do
  use Mix.Project

  def project do
    [
      name: "DuckDuck",
      description: "A Mix Task to upload Distillery releases to GitHub.",
      app: :duckduck,
      version: "1.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test,
        bless: :test
      ],
      package: package(),
      source_url: "https://github.com/the-mikedavis/duckduck.git"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.4"},
      {:ex_doc, "~> 0.19.1", only: :dev},
      {:credo, "~> 0.9.1", only: :test, runtime: false},
      {:excoveralls, "~> 0.7", only: :test},
      {:private, "~> 0.1.1"},
      {:mox, "~> 0.4", only: :test},
      {:ecto, ">= 2.0.0"},
      {:dialyxir, "~> 1.0.0-rc.4"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: "duckduck",
      licenses: ["BSD3"],
      links: %{"GitHub" => "https://github.com/the-mikedavis/duckduck.git"},
      files: ~w(lib LICENSE mix.exs README.md .formatter.exs),
      maintainers: ["Michael Davis"]
    ]
  end

  defp aliases do
    [
      bless: [&bless/1]
    ]
  end

  defp bless(_) do
    [
      {"compile", ["--warnings-as-errors", "--force"]},
      {"coveralls.html", []},
      {"format", ["--check-formatted"]},
      {"credo", []}
    ]
    |> Enum.each(fn {task, args} ->
      IO.ANSI.format([:cyan, "Running #{task} with args #{inspect(args)}"])
      |> IO.puts()

      Mix.Task.run(task, args)
    end)
  end
end
