defmodule Mix.Tasks.Goose do
  use Mix.Task
  alias DuckDuck.CLI
  import DuckDuck.Transform

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
    argv
    |> CLI.parse()
    |> put_owner_and_repo()
    |> put_tag()
    |> put_path()
    |> put_accept()
    |> put_api_token()
    |> upload()
    |> IO.ANSI.format()
    |> IO.puts()
  end
end
