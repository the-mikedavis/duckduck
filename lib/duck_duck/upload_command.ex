defmodule DuckDuck.UploadCommand do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset

  @effects Application.get_env(:duckduck, :effects_client, DuckDuck.Effects)

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
    field(:accept?, :boolean)
    field(:api_token, :string)
    field(:upload_url, :string)
  end

  @spec transform(%__MODULE__{}, map()) :: %__MODULE__{} | {:error, String.t()}
  def transform(changeset, params \\ %{}) do
    changeset
    |> cast(params, @fields)
    |> validate_confirmation()
    |> validate_file_exists()
    |> validate_format(:api_token, ~r/^\w+$/)
    |> validate_token()
    |> case do
      %Changeset{valid?: true} = changeset ->
        apply_changes(changeset)

      %Changeset{errors: errors} ->
        {:error, join_errors(errors)}
    end
  end

  @spec join_errors(Keyword.t()) :: String.t()
  defp join_errors(errors) do
    errors
    |> Enum.map(fn {key, {message, _}} ->
      ["Validation for '#{key}' ", :red, "failed", :reset, ": #{message}"]
      |> IO.ANSI.format()
      |> IO.chardata_to_string()
    end)
    |> Enum.join("\n")
  end

  @spec validate_confirmation(Changeset.t()) :: Changeset.t()
  def validate_confirmation(changeset) do
    validate_change(changeset, :accept?, :confirmation, fn
      :accept?, true -> []
      :accept?, false -> [accept?: "User aborted."]
    end)
  end

  # ensure that the file does exist before I try to upload it
  @spec validate_file_exists(Changeset.t()) :: Changeset.t()
  defp validate_file_exists(changeset) do
    validate_change(changeset, :path, :exists, fn :path, path ->
      case @effects.exists?(path) do
        true -> []
        false -> [path: "No release files found at #{path}"]
      end
    end)
  end

  @token_check_error "GitHub rejected this token. Check the token permissions"

  # api keys should bounce off the endpoint without errors
  @spec validate_token(Changeset.t()) :: Changeset.t()
  defp validate_token(
         %Changeset{data: %__MODULE__{owner: owner, repo: repo}} = changeset
       ) do
    validate_change(changeset, :api_token, :permissions, fn _, token ->
      case DuckDuck.valid_token?(token, owner, repo) do
        true -> []
        false -> [api_token: @token_check_error]
      end
    end)
  end
end
