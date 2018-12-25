defmodule DuckDuck.CLI do
  @moduledoc """
  Command line interface for uploading release artifacts.
  """

  import DuckDuck
  alias Mix.Project

  @switches [tag: :string, file: :string, yes: :boolean]
  @aliases [t: :tag, f: :file, y: :yes]

  def parse!(argv) do
    {parsed, _rest} =
      OptionParser.parse!(argv, switches: @switches, aliases: @aliases)

    Map.new(parsed)
  end

  # fill in missing values

  def resolve!(%{tag: _tag, file: _file} = opts), do: opts

  def resolve!(%{file: _file} = opts), do: Map.put(opts, :tag, get_tag())

  def resolve!(%{tag: tag} = opts) do
    app_name = Keyword.fetch!(Project.config(), :app)

    file =
      case release_files(app_name, tag, Project.build_path()) do
        [file] ->
          file

        [] ->
          fail("No local release files found for #{tag}!")

        [_ | _] ->
          fail("Found too many local release files for #{tag}")
      end

    Map.put(opts, :file, file)
  end

  def resolve!(opts) do
    opts
    |> Map.put(:tag, get_tag())
    |> resolve!()
  end

  def confirm!(%{yes: true} = opts), do: opts

  def confirm!(%{file: file, tag: tag} = opts) do
    "I want to upload #{file} to tag #{tag}.\nIs this ok? [Y/n] "
    |> IO.gets()
    |> String.trim()
    |> String.downcase()
    |> case do
      "" ->
        Map.put(opts, :yes, true)

      "y" <> _ ->
        Map.put(opts, :yes, true)

      _ ->
        fail("Aborting!")
    end
  end

  def run!(%{tag: tag, file: file, yes: true}) do
    {:ok, _all} = Application.ensure_all_started(:httpoison)

    owner = Application.fetch_env!(:duckduck, :owner)
    repo = Application.fetch_env!(:duckduck, :repo)
    api_token = read_api_token()

    unless valid_token?(api_token, owner, repo) do
      fail("GitHub doesn't think this token is valid!")
    end

    upload_url = find_upload_url(api_token, owner, repo, tag)

    upload(file, api_token, upload_url)
  end
end
