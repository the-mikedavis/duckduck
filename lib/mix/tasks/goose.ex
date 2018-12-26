defmodule Mix.Tasks.Goose do
  use Mix.Task
  alias DuckDuck.{CLI, DeadDuckError}

  @moduledoc """
  A mix task to upload distillery releases to GitHub.

  ## Usage

  ```
  mix goose
  ```

  ## Flags

  - `--tag <tag>` or `-t <tag>`: specify the tag you want to upload
  - `--file <path>` or `-f <path>`: specify the file you want to upload
  - `--yes` or `-y`: don't ask for confirmation; useful for running non-interactively
  """

  @shortdoc "A mix task to upload distillery releases to GitHub."
  @recursive false

  @doc "Upload a release artifact to GitHub."
  def run(argv) do
    try do
      argv
      |> CLI.parse!()
      |> CLI.resolve!()
      |> CLI.confirm!()
      |> CLI.run!()
    rescue
      e in DeadDuckError ->
        DuckDuck.puts_failure(e.message)

        System.halt(1)
    end
  end
end
