defmodule DuckDuck.UploadCommand do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @moduledoc """
  A command to upload a tarball to GitHub.

  Includes such valuable information as

  - whether the user has confirmed the command
  - the path to the file to upload
  - the tag to which to upload
  """

  @type t :: %__MODULE__{}

  @fields [:accept?, :path, :tag, :api_token, :owner, :repo, :upload_url]

  embedded_schema do
    field(:owner, :string)
    field(:repo, :string)
    field(:tag, :string)
    field(:path, :string)
    field(:accept?, :boolean, default: false)
    field(:api_token, :string)
    field(:upload_url, :string)
  end

  @doc """
  Apply changes to an ecto changeset of this command.
  """
  @spec changeset(__MODULE__.t()) :: Ecto.Changeset.t()
  @spec changeset(__MODULE__.t(), %{}) :: Ecto.Changeset.t()
  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_acceptance(:accept?)
    |> validate_file_exists()
    # api keys are alphanumeric from start to finish
    |> validate_format(:api_token, ~r/^\w+$/)
    |> validate_token()
  end

  # ensure that the file does exist before I try to upload it
  @spec validate_file_exists(Changeset.t()) :: Changeset.t()
  defp validate_file_exists(changeset) do
    validate_change(changeset, :path, :exists, fn (_, path) ->
      case File.exists?(path) do
        true -> []
        false -> [path: "No release files found at #{path}"]
      end
    end)
  end

  @token_check_error "GitHub rejected this token. Check the token permissions"

  # api keys should bounce off the endpoint without errors
  @spec validate_token(Changeset.t()) :: Changeset.t()
  defp validate_token(%Changeset{changes: changes} = changeset) do
    validate_change(changeset, :api_token, :permissions, fn _, token ->
      case DuckDuck.valid_token?(token, changes.owner, changes.repo) do
        true -> []
        false -> [api_token: @token_check_error]
      end
    end)
  end
end
