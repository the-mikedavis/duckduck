defmodule Mix.Tasks.Goose do
  use Mix.Task
  alias DuckDuck.CLI

  @moduledoc """
  A mix task to upload distillery releases to GitHub.
  """

  @shortdoc "A mix task to upload distillery releases to GitHub."
  @recursive false

  @doc "Upload a release artifact to GitHub."
  def run(argv) do
    argv
    |> CLI.parse!()
    |> CLI.resolve!()
    |> CLI.confirm!()
    |> CLI.run!()
  end
end
