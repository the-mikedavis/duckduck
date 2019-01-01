defmodule DuckDuck.Transform do
  alias DuckDuck.UploadCommand, as: Command

  @moduledoc """
  Describes a series of transformations to iteratively build an UploadCommand.
  """

  @effects Application.get_env(:duckduck, :effects_client, DuckDuck.Effects)

  @switches [tag: :string, path: :string, yes: :boolean]
  @aliases [t: :tag, f: :path, y: :yes]

  @doc "Transform an argument list into a command command"
  @spec parse([String.t()]) :: Command.t()
  def parse(argv) do
    {parsed, _rest} =
      OptionParser.parse!(argv, switches: @switches, aliases: @aliases)

    params =
      parsed
      |> Enum.map(&translate/1)
      |> Enum.into(%{})

    Command.transform(%Command{}, params)
  end

  # translate to the keys of the UploadCommand schema
  @spec translate({atom(), any()}) :: {atom(), any()}
  defp translate({:yes, accepted?}), do: {:accept?, accepted?}
  defp translate({:file, path}), do: {:path, path}
  defp translate(pair), do: pair

  @doc """
  Put the owner in the changeset if not already there
  """
  @spec owner(Command.t()) :: Command.t() | {:error, String.t()}
  def owner(command) do
    case @effects.fetch_env(:duckduck, :owner) do
      {:ok, owner} ->
        Command.transform(command, %{owner: owner})

      :error ->
        {:error, "Couldn't find repo owner in config"}
    end
  end

  @doc """
  Put the repo in the command if not already there
  """
  @spec repo(Command.t()) :: Command.t() | {:error, String.t()}
  def repo(command) do
    case @effects.fetch_env(:duckduck, :repo) do
      {:ok, repo} ->
        Command.transform(command, %{repo: repo})

      :error ->
        {:error, "Couldn't find repo name in config"}
    end
  end

  @doc """
  Put the tag in a command if the command is not already valid.
  """
  @spec tag(Command.t()) :: Command.t()
  def tag(command) do
    Command.transform(command, %{tag: @effects.get_tag()})
  end

  @doc """
  Put the path to the upload file in the command if not already present
  and valid.
  """
  @spec path(Command.t()) :: Command.t() | {:error, String.t()}
  def path(%Command{tag: tag} = command) do
    case DuckDuck.find_release_file(tag) do
      {:ok, file} ->
        Command.transform(command, %{path: file})

      {:error, _reason} = e ->
        e
    end
  end

  @doc """
  Put the acceptance if the user has confirmed.
  """
  @spec accept?(Command.t()) :: Command.t()
  def accept?(%Command{tag: tag, path: path} = command) do
    Command.transform(command, %{accept?: DuckDuck.confirm(path, tag)})
  end

  @doc """
  Put the api token in the command if not already there.
  """
  @spec api_token(Command.t()) :: Command.t() | {:error, String.t()}
  def api_token(command) do
    case @effects.read_api_token() do
      {:ok, token} ->
        Command.transform(command, %{api_token: token})

      {:error, _reason} = e ->
        e
    end
  end

  @doc """
  Find the upload url and put it in the command.

  For uploading assets, you need to ask GitHub where to put them through
  their API. Interestingly, you can't upload assets to a tag. Only a release
  may have assets. So when you want to upload to a tag, you must also create
  the release from the tag. You can do this with a single API call.
  """
  @spec upload_url(Command.t()) :: Command.t() | {:error, String.t()}
  def upload_url(
        %Command{api_token: token, owner: owner, repo: repo, tag: tag} = command
      ) do
    if Enum.any?([token, owner, repo, tag], &is_nil/1) do
      {:error,
       """
       Couldn't find the upload url because I didn't know at least one of
       - api token
       - repo owner
       - repo name
       - tag
       """}
    else
      Command.transform(command, %{
        upload_url: DuckDuck.find_upload_url(token, owner, repo, tag)
      })
    end
  end

  @spec upload(Command.t()) :: IO.chardata()
  def upload(%Command{path: path, api_token: api_token, upload_url: url}) do
    IO.puts("Please wait. Uploading #{path}...")

    case DuckDuck.upload(path, api_token, url) do
      :ok ->
        [:green, "Release successfully uploaded", :reset, "."]

      {:error, reason} ->
        [:red, reason]
    end
  end

  def upload(%Command{}) do
    ["Release upload ", :red, "failed", :reset, ".\n"]
  end
end
