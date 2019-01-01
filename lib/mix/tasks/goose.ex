defmodule Mix.Tasks.Goose do
  use Mix.Task
  alias DuckDuck.Transform
  alias DuckDuck.UploadCommand, as: Command

  @effects Application.get_env(:duckduck, :effects_client, DuckDuck.Effects)

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

  @transformations [
    :owner,
    :repo,
    :tag,
    :path,
    :api_token,
    :accept?,
    :upload_url
  ]

  @doc "Upload a release artifact to GitHub."
  def run(argv) do
    @effects.start_http_client()

    @transformations
    |> Enum.reduce(Transform.parse(argv), &transform/2)
    |> Transform.upload()
    |> IO.ANSI.format()
    |> IO.puts()
  end

  @spec transform(atom(), Command.t()) ::
          {:ok, Command.t()} | {:error, String.t()}
  defp transform(key, accumulator) do
    # first clause catches failed validations from command line arguments
    # like a path not existing passed in through `-f`
    with %Command{} <- accumulator,
         {:ok, nil} <- Map.fetch(accumulator, key),
         %Command{} = command <- apply(Transform, key, [accumulator]) do
      command
    else
      # failure acquiring any key
      {:error, reason} ->
        @effects.puts(:stderr, IO.ANSI.format([:red, reason]))

        exit(:shutdown)

      # the key already existed, so no transformation necessary
      {:ok, _value} ->
        accumulator
    end
  end
end
