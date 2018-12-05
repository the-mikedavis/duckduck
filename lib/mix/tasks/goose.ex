defmodule Mix.Tasks.Goose do
  use Mix.Task

  import DuckDuck

  @moduledoc """
  A mix task to upload distillery releases to GitHub.
  """

  @shortdoc "A mix task to upload distillery releases to GitHub."
  @recursive false

  def run([tag]) do
    {:ok, _all} = Application.ensure_all_started(:httpoison)

    app_name =
      Mix.Project.config()
      |> Keyword.fetch!(:app)

    owner = Application.fetch_env!(:goose, :owner)
    repo = Application.fetch_env!(:goose, :repo)

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
end
