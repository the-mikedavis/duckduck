defmodule Mix.Tasks.Goose do
  use Mix.Task

  import DuckDuck

  @moduledoc """
  A mix task to upload distillery releases to GitHub.
  """

  @shortdoc "A mix task to upload distillery releases to GitHub."
  @recursive false

  @doc "Upload a release artifact to GitHub."
  def run(argv)

  def run([]) do
    if Mix.env() == :prod do
      {tag_string, 0} = System.cmd("git", ["describe", "--abbrev=0"])
      tag = String.trim(tag_string)

      run([tag])
    else
      usage_and_exit()
    end
  end

  def run([tag]) do
    {:ok, _all} = Application.ensure_all_started(:httpoison)

    app_name =
      Mix.Project.config()
      |> Keyword.fetch!(:app)

    owner = Application.fetch_env!(:duckduck, :owner)
    repo = Application.fetch_env!(:duckduck, :repo)

    with [release] <- release_files(app_name, tag, Mix.Project.build_path()),
         api_token <- read_api_token(),
         true <- valid_token?(api_token, owner, repo),
         upload_url <- find_upload_url(api_token, owner, repo, tag) do
      upload(release, api_token, upload_url)
    else
      [] ->
        puts_failure("No local release files found for #{tag}!")

      [_ | _] ->
        puts_failure("Found too many local release files for #{tag}")
    end
  end

  def run(_), do: usage_and_exit()

  defp usage_and_exit do
    IO.puts("Usage: `MIX_ENV=<env> mix goose [<tag>]`")

    System.halt(1)
  end
end
