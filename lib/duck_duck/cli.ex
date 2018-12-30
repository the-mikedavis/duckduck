defmodule DuckDuck.CLI do
  @moduledoc """
  Command line interface for uploading release artifacts.
  """

  import DuckDuck
  alias Ecto.Changeset
  alias DuckDuck.{Effects, UploadCommand}
  use Private

  @switches [tag: :string, path: :string, yes: :boolean]
  @aliases [t: :tag, f: :path, y: :yes]

  @effects Application.get_env(:duckduck, :effects_client, Effects)

  @spec parse([String.t()]) :: Changeset.t()
  def parse(argv) do
    {parsed, _rest} =
      OptionParser.parse!(argv, switches: @switches, aliases: @aliases)

    # translate to the keys of the UploadCommand schema
    params =
      parsed
      |> Map.new()
      |> Enum.map(&translate/1)

    UploadCommand.changeset(%UploadCommand{}, params)
  end


  def run(%{tag: tag, path: path, yes: true}) do
    @effects.start_http_client()

    owner = Application.fetch_env!(:duckduck, :owner)
    repo = Application.fetch_env!(:duckduck, :repo)
    api_token = @effects.read_api_token()

    # unless valid_token?(api_token, owner, repo) do
    # fail("GitHub doesn't think this token is valid!")
    # end

    upload_url = find_upload_url(api_token, owner, repo, tag)

    upload(path, api_token, upload_url)
  end

  private do
    defp translate({:yes, accepted?}), do: {:accept?, accepted?}
    defp translate(pair), do: pair
  end
end
