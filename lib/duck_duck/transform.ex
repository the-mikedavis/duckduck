defmodule DuckDuck.Transform do
  alias Ecto.Changeset
  alias DuckDuck.UploadCommand, as: Command

  @effects Application.get_env(:duckduck, :effects_client, DuckDuck.Effects)

  @switches [tag: :string, path: :string, yes: :boolean]
  @aliases [t: :tag, f: :path, y: :yes]

  @doc "Transform an argument list into a command changeset"
  @spec parse([String.t()]) :: Changeset.t()
  def parse(argv) do
    {parsed, _rest} =
      OptionParser.parse!(argv, switches: @switches, aliases: @aliases)

    params =
      parsed
      |> Enum.map(&translate/1)
      |> Enum.into(%{})

    Command.changeset(%Command{}, params)
  end

  # translate to the keys of the UploadCommand schema
  @spec translate({atom(), any()}) :: {atom(), any()}
  defp translate({:yes, accepted?}), do: {:accept?, accepted?}
  defp translate({:file, path}), do: {:path, path}
  defp translate(pair), do: pair

  @doc """
  Put the owner in the changeset if not already there
  """
  @spec put_owner(Changeset.t()) :: Changeset.t()
  def put_owner(%Changeset{changes: %{owner: _owner}} = changeset),
    do: changeset

  def put_owner(changeset) do
    case @effects.fetch_env(:duckduck, :owner) do
      {:ok, owner} ->
        Command.changeset(changeset, %{owner: owner})

      :error ->
        Changeset.add_error(
          changeset,
          :owner,
          "Couldn't find repo owner in config"
        )
    end
  end

  @doc """
  Put the repo in the changeset if not already there
  """
  @spec put_repo(Changeset.t()) :: Changeset.t()
  def put_repo(%Changeset{changes: %{repo: _repo}} = changeset), do: changeset

  def put_repo(changeset) do
    case @effects.fetch_env(:duckduck, :repo) do
      {:ok, repo} ->
        Command.changeset(changeset, %{repo: repo})

      :error ->
        Changeset.add_error(
          changeset,
          :repo,
          "Couldn't find repo name in config"
        )
    end
  end

  @doc """
  Put the tag in a changeset if the changeset is not already valid.
  """
  @spec put_tag(Changeset.t()) :: Changeset.t()
  def put_tag(%Changeset{changes: %{tag: _tag}} = changeset), do: changeset

  def put_tag(changeset) do
    Command.changeset(changeset, %{tag: @effects.get_tag()})
  end

  @doc """
  Put the path to the upload file in the changeset if not already present
  and valid.
  """
  @spec put_path(Changeset.t()) :: Changeset.t()
  def put_path(%Changeset{changes: %{path: _path}} = changeset), do: changeset

  def put_path(%Changeset{changes: %{tag: tag}} = changeset) do
    case DuckDuck.find_release_file(tag) do
      {:ok, file} ->
        Command.changeset(changeset, %{path: file})

      {:error, reason} ->
        Changeset.add_error(changeset, :path, reason)
    end
  end

  def put_path(changeset), do: changeset

  @doc """
  Put the acceptance if the user has confirmed.
  """
  @spec put_accept(Changeset.t()) :: Changeset.t()
  def put_accept(%Changeset{changes: %{accept?: true}} = changeset),
    do: changeset

  def put_accept(%Changeset{changes: %{tag: tag, path: path}} = changeset) do
    Command.changeset(changeset, %{accept?: DuckDuck.confirm(path, tag)})
  end

  # if either path or tag are not present, it's fine to just pass through
  def put_accept(changeset), do: changeset

  @doc """
  Put the api token in the changeset if not already there.
  """
  @spec put_api_token(Changeset.t()) :: Changeset.t()
  def put_api_token(%Changeset{changes: %{api_token: _token}} = changeset),
    do: changeset

  def put_api_token(changeset) do
    Command.changeset(changeset, %{api_token: @effects.read_api_token()})
  end

  @doc """
  Find the upload url and put it in the changeset.

  For uploading assets, you need to ask GitHub where to put them through
  their API. Interestingly, you can't upload assets to a tag. Only a release
  may have assets. So when you want to upload to a tag, you must also create
  the release from the tag. You can do this with a single API call.
  """
  @spec put_upload_url(Changeset.t()) :: Changeset.t()
  def put_upload_url(
        %Changeset{
          changes: %{api_token: token, owner: owner, repo: repo, tag: tag}
        } = changeset
      ) do
    Command.changeset(changeset, %{
      upload_url: DuckDuck.find_upload_url(token, owner, repo, tag)
    })
  end

  def put_upload_url(changeset) do
    Changeset.add_error(
      changeset,
      :upload_url,
      """
      Couldn't find the upload url because I didn't know at least one of
      - api token
      - repo owner
      - repo name
      - tag
      """
    )
  end

  @spec upload(Changeset.t()) :: IO.chardata()
  def upload(%Changeset{
        changes: %{path: path, api_token: api_token, upload_url: url},
        valid?: true
      }) do
    IO.puts("Please wait. Uploading #{path}...")

    case DuckDuck.upload(path, api_token, url) do
      :ok ->
        [:green, "Release successfully uploaded", :reset, "."]

      {:error, reason} ->
        [:red, reason]
    end
  end

  def upload(%Changeset{errors: errors}) do
    fail_message = ["Release upload ", :red, "failed", :reset, ".\n"]

    Enum.reduce(errors, fail_message, fn {key, {message, _}}, acc ->
      acc ++ [:red, "#{key}", :reset, ":\n", message, "\n"]
    end)
  end
end
