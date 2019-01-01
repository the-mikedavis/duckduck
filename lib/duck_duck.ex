defmodule DuckDuck do
  use Private
  alias Mix.Project
  @moduledoc false
  # Helper functions for finding release artifacts and uploading them.

  alias __MODULE__.Effects
  @effects Application.get_env(:duckduck, :effects_client, Effects)

  @doc "Checks if a token is valid by bouncing of an API endpoint"
  @spec valid_token?(String.t(), String.t(), String.t()) :: boolean()
  def valid_token?(api_token, owner, repo) do
    owner
    |> token_check_url(repo)
    |> @effects.get(auth_header(api_token))
    |> ok_http_response?()
  end

  @doc "Gets the url for artifact upload from the GitHub API"
  @spec find_upload_url(String.t(), String.t(), String.t(), String.t()) ::
          String.t()
  def find_upload_url(api_token, owner, repo, tag) do
    owner
    |> tags_url(repo, tag)
    |> @effects.get!(auth_header(api_token))
    |> Map.get(:body)
    |> Jason.decode!()
    |> translate_upload_url()
    |> case do
      {:error, :not_found} ->
        create_release_from_tag(api_token, owner, repo, tag)

      {:ok, url} ->
        url
    end
    |> String.replace(~r/\{.*\}/, "")
  end

  @doc "Tells GitHub to create a release from a tag"
  @spec create_release_from_tag(String.t(), String.t(), String.t(), String.t()) ::
          String.t()
  def create_release_from_tag(api_token, owner, repo, tag) do
    owner
    |> release_creation_url(repo)
    |> @effects.post!(
      Jason.encode!(%{"tag_name" => tag}),
      auth_header(api_token)
    )
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("upload_url")
  end

  @doc "Asks the user for confirmation"
  @spec confirm(String.t(), String.t()) :: boolean()
  def confirm(path, tag) do
    "I want to upload #{path} to tag #{tag}.\nIs this ok? [Y/n] "
    |> IO.gets()
    |> String.trim()
    |> String.downcase()
    |> case do
      "" -> true
      "y" <> _ -> true
      _ -> false
    end
  end

  @doc """
  Attempt to find the proper file to upload based on the tag.

  If there are no files, or more than one file matching the glob, an
  error tuple is returned.
  """
  @spec find_release_file(String.t()) :: {:ok, Path.t()} | {:error, String.t()}
  def find_release_file(tag) do
    Project.config()
    |> Keyword.fetch!(:app)
    |> @effects.release_files(tag, @effects.build_path())
    |> case do
      [path] ->
        {:ok, path}

      [] ->
        {:error, "No local release paths found for #{tag}!"}

      [_ | _] ->
        {:error, "Found too many local release paths for #{tag}!"}
    end
  end

  @doc "Uploads a file to an endpoint"
  @spec upload(Path.t(), String.t(), String.t()) :: :ok | {:error, String.t()}
  def upload(path, api_token, upload_url) do
    upload_url
    |> upload_asset_url(path)
    |> @effects.post_file!(path, auth_header(api_token))
    |> Map.get(:body)
    |> Jason.decode!()
    |> good_upload?()
  end

  private do
    @spec auth_header(String.t()) :: [{String.t(), String.t()}]
    defp auth_header(token), do: [{"Authorization", "token #{token}"}]

    @spec token_check_url(String.t(), String.t()) :: String.t()
    defp token_check_url(owner, repo) do
      "https://api.github.com/repos/#{owner}/#{repo}"
    end

    @spec tags_url(String.t(), String.t(), String.t()) :: String.t()
    defp tags_url(owner, repo, tag) do
      token_check_url(owner, repo) <> "/releases/tags/#{tag}"
    end

    @spec upload_asset_url(String.t(), String.t()) :: String.t()
    defp upload_asset_url(upload_url, asset_path) do
      upload_url <> "?name=" <> Path.basename(asset_path)
    end

    @spec release_creation_url(String.t(), String.t()) :: String.t()
    defp release_creation_url(owner, repo) do
      token_check_url(owner, repo) <> "/releases"
    end

    defp ok_http_response?({:ok, %HTTPoison.Response{status_code: status}})
         when status in 200..206,
         do: true

    defp ok_http_response?(_), do: false

    defp translate_upload_url(%{"message" => "Not Found"}),
      do: {:error, :not_found}

    defp translate_upload_url(%{"upload_url" => url}), do: {:ok, url}

    @spec good_upload?(%{}) :: :ok | {:error, String.t()}
    defp good_upload?(%{"errors" => [%{"code" => "already_exists"}]}) do
      {:error,
       """
       GitHub said that there's already a release artifact with this name for
       this tag! Make a new tag and trying again.
       """}
    end

    defp good_upload?(%{"message" => "Not Found"}) do
      {:error, "I could not write to this tag! Check your token and try again."}
    end

    # denotes that a release was successfully uploaded
    defp good_upload?(%{"content_type" => "application/octet-stream"}), do: :ok
  end
end
