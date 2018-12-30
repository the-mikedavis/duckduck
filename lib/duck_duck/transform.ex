defmodule DuckDuck.Transform do
  alias Ecto.Changeset
  alias DuckDuck.UploadCommand, as: Command

  @effects Application.get_env(:duckduck, :effects_client, DuckDuck.Effects)

  @doc """
  Put the owner and repo in the changeset if not already there
  """
  @spec put_owner_and_repo(Changeset.t()) :: Changeset.t()
  def put_owner_and_repo(%Changeset{valid?: true} = changeset), do: changeset
  def put_owner_and_repo(changeset) do
    with {:ok, owner} <- Application.fetch_env(:duckduck, :owner),
         {:ok, repo} <- Application.fetch_env(:duckduck, :repo) do
      Command.changeset(changeset, %{owner: owner, repo: repo})
    end
  end

  @doc """
  Put the tag in a changeset if the changeset is not already valid.
  """
  @spec put_tag(Changeset.t()) :: Changeset.t()
  def put_tag(%Changeset{valid?: true} = changeset), do: changeset
  def put_tag(changeset) do
    case Changeset.fetch_change(changeset, :tag) do
      {:changes, _tag} -> changeset

      :error ->
        Command.changeset(changeset, %{tag: @effects.get_tag()})
    end
  end

  @doc """
  Put the path to the upload file in the changeset if not already present
  and valid.
  """
  @spec put_path(Changeset.t()) :: Changeset.t()
  def put_path(%Changeset{valid?: true} = changeset), do: changeset
  def put_path(changeset) do
    with :error <-  Changeset.fetch_change(changeset, :path),
         {:ok, tag} <- Changeset.fetch_change(changeset, :tag),
         {:ok, file} <- DuckDuck.find_release_file(tag) do
      Command.changeset(changeset, %{path: file})
    else
      # there was an error sourcing the files
      {:error, reason} ->
        Changeset.add_error(changeset, :path, reason)

      # the changeset already has a suitable path change
      {:changes, _path} ->
        changeset

      # the tag is not in the changes
      :error ->
        changeset
    end
  end

  @doc """
  Put the acceptance if the user has confirmed.
  """
  @spec put_accept(Changeset.t()) :: Changeset.t()
  def put_accept(changeset) do
    with :error <- Changeset.fetch_change(changeset, :accept?),
         {:changes, tag} <- Changeset.fetch_change(changeset, :tag),
         {:changes, path} <- Changeset.fetch_change(changeset, :path) do
      Command.changeset(changeset, %{accept?: DuckDuck.confirm(path, tag)})
    else
      # either the tag or path fields are invalid, so just fall through
      :error ->
        changeset

      # the changeset was already confirmed (matches first clause)
      {:changes, true} ->
        changeset
    end
  end

  @doc """
  Put the api token in the changeset if not already there.
  """
  @spec put_api_token(Changeset.t()) :: Changeset.t()
  def put_api_token(%Changeset{valid?: true} = changeset), do: changeset
  def put_api_token(changeset) do
    # there's no other way to put that api_token in the changeset for now.
    # that's why this function is so simple.
    # path and tag and confirm have cli flags
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
  def put_upload_url(%Changeset{changes: %{api_token: token, owner: owner, repo: repo, tag: tag}} = changeset) do
    Command.changeset(changeset, %{upload_url: DuckDuck.find_upload_url(token, owner, repo, tag)})
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
      """)
  end

  @spec upload(Changeset.t()) :: IO.chardata()
  def upload(%Changeset{changes: %{path: path, api_token: api_token, upload_url: url}, valid?: true}) do
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

    Enum.reduce(errors, fail_message, fn {key, message}, acc ->
      acc ++ [:red, "#{key}", :reset, ":\n", message, "\n"]
    end)
  end
end
