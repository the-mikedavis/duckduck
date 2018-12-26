defmodule DuckDuck do
  use Private
  @moduledoc false
  # Helper functions for finding release artifacts and uploading them.

  alias __MODULE__.{DeadDuckError, Effects}
  @effects Application.get_env(:duckduck, :effects_client, Effects)

  # print in green
  def puts_success(str) do
    [:green, str]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  # print in red
  def puts_failure(str) do
    [:red, str]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  def fail(str), do: raise(DeadDuckError, message: str)

  @spec valid_token?(String.t(), String.t(), String.t()) :: boolean()
  def valid_token?(api_token, owner, repo) do
    headers = auth_header(api_token)

    owner
    |> build_token_check_url(repo)
    |> @effects.get(headers)
    |> valid?()
  end

  @spec find_upload_url(String.t(), String.t(), String.t(), String.t()) ::
          String.t()
  def find_upload_url(api_token, owner, repo, tag) do
    headers = auth_header(api_token)

    owner
    |> build_tags_url(repo, tag)
    |> @effects.get!(headers)
    |> Map.get(:body)
    |> Jason.decode!()
    |> validate_upload_url()
    |> case do
      {:error, :not_found} ->
        create_release_from_tag(api_token, owner, repo, tag)

      {:ok, url} ->
        url
    end
    |> String.replace(~r/\{.*\}/, "")
  end

  @spec create_release_from_tag(String.t(), String.t(), String.t(), String.t()) ::
          String.t()
  def create_release_from_tag(api_token, owner, repo, tag) do
    headers = auth_header(api_token)
    body = Jason.encode!(%{"tag_name" => tag})

    owner
    |> build_release_creation_url(repo)
    |> @effects.post!(body, headers)
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("upload_url")
  end

  def upload(path, api_token, upload_url) do
    headers = auth_header(api_token)

    puts_success("Please wait. Uploading #{path}...")

    upload_url
    |> build_upload_asset_url(path)
    |> @effects.post_file!(path, headers)
    |> Map.get(:body)
    |> Jason.decode!()
    |> good_upload?()
  end

  private do
    @spec auth_header(String.t()) :: [{String.t(), String.t()}]
    defp auth_header(token), do: [{"Authorization", "token #{token}"}]

    @spec build_token_check_url(String.t(), String.t()) :: String.t()
    defp build_token_check_url(owner, repo) do
      "https://api.github.com/repos/#{owner}/#{repo}"
    end

    @spec build_tags_url(String.t(), String.t(), String.t()) :: String.t()
    defp build_tags_url(owner, repo, tag) do
      build_token_check_url(owner, repo) <> "/releases/tags/#{tag}"
    end

    @spec build_upload_asset_url(String.t(), String.t()) :: String.t()
    defp build_upload_asset_url(upload_url, asset_path) do
      upload_url <> "?name=" <> Path.basename(asset_path)
    end

    @spec build_release_creation_url(String.t(), String.t()) :: String.t()
    defp build_release_creation_url(owner, repo) do
      build_token_check_url(owner, repo) <> "/releases"
    end

    defp valid?({:ok, %HTTPoison.Response{}}), do: true
    defp valid?(_), do: false

    defp validate_upload_url(%{"message" => "Not Found"}),
      do: {:error, :not_found}

    defp validate_upload_url(%{"upload_url" => url}), do: {:ok, url}

    defp good_upload?(%{"errors" => [%{"code" => "already_exists"}]}) do
      puts_failure("""
      GitHub said that there's already a release artifact with this name for
      this tag! Make a new tag and trying again.
      """)
    end

    defp good_upload?(%{"message" => "Not Found"}) do
      puts_failure("""
      I could not write to this tag! Check your token and try again.
      """)
    end

    # denotes that a release was successfully uploaded
    defp good_upload?(%{"content_type" => "application/octet-stream"}) do
      puts_success("Release successfully uploaded")
    end
  end
end
