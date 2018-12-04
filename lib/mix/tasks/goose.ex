defmodule Mix.Tasks.Goose do
  use Mix.Task
  @moduledoc """
  A mix task to upload distillery releases to GitHub.
  """

  @shortdoc "A mix task to upload distillery releases to GitHub."
  @recursive false

  def run([tag]) do
    config = Mix.Project.config()

    app_name = Keyword.fetch!(config, :app)

    with [release] <- release_files(app_name, tag) do
      IO.inspect(release)
    else
      [] ->
        Mix.Shell.IO.error("No release files found for #{tag}!")
      [_ | _] ->
        Mix.Shell.IO.error("Found too many release files for #{tag}")
    end
  end

  defp release_files(name, tag) do
    [Mix.Project.build_path(), "rel", "#{name}", "releases", "#{tag}*", "#{name}.tar.gz"]
    |> Path.join()
    |> Path.wildcard()
  end
end
