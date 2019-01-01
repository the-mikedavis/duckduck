defmodule DuckDuck.Effects do
  @moduledoc false

  alias Mix.Project

  defmodule Behaviour do
    @moduledoc false

    @callback get_tag() :: String.t()
    @callback release_files(atom(), String.t(), Path.t()) :: [Path.t()]
    @callback build_path() :: Path.t()
    @callback read_api_token() :: {:ok | :error, String.t()}
    @callback start_http_client() :: :ok
    @callback post_file!(String.t(), Path.t(), [{String.t(), String.t()}]) ::
                %HTTPoison.Response{}
    @callback post!(String.t(), binary(), [{String.t(), String.t()}]) ::
                %HTTPoison.Response{}
    @callback get!(String.t(), [{String.t(), String.t()}]) ::
                %HTTPoison.Response{}
    @callback get(String.t(), [{String.t(), String.t()}]) ::
                {:ok, %HTTPoison.Response{}} | {:error, any()}
    @callback exists?(Path.t()) :: boolean()
    @callback fetch_env(atom(), atom()) :: {:ok, any()} | :error
    @callback puts(IO.chardata()) :: :ok
    @callback puts(atom(), IO.chardata()) :: :ok
  end

  @behaviour __MODULE__.Behaviour

  # side effects like
  # - http reqs
  # - reading envs from the system
  # - reading from git
  # - file operations

  # read the tag from `git`
  @impl true
  def get_tag do
    {tag_string, 0} = System.cmd("git", ["describe", "--tags"])

    String.trim(tag_string)
  end

  # given an app name, get the name of the release artifact
  @impl true
  def release_files(app, tag, build_path) do
    [build_path, "rel", "#{app}", "releases", "#{tag}*", "#{app}.tar.gz"]
    |> Path.join()
    |> Path.wildcard()
  end

  @impl true
  def build_path, do: Project.build_path()

  # read the api token either from System.get_env or from the token file
  @impl true
  def read_api_token do
    token_file =
      :duckduck
      |> Application.get_env(:token_file, "~/.goose_api_token")
      |> Path.expand()

    with :error <- Application.fetch_env(:duckduck, :api_token),
         true <- File.exists?(token_file),
         {:ok, contents} <- File.read(token_file) do
      {:ok, String.trim(contents)}
    else
      # user put their api token in the config (matches first clause)
      {:ok, api_token} ->
        {:ok, api_token}

      # the file doesn't exist
      false ->
        {:error, "The token file cannot be found."}

      {:error, reason} ->
        {:error, "The token file could not be read: #{reason}"}
    end
  end

  @impl true
  def start_http_client do
    {:ok, _all} = Application.ensure_all_started(:httpoison)

    :ok
  end

  @impl true
  def post_file!(url, path, headers) do
    HTTPoison.post!(url, {:file, path}, headers,
      timeout: :infinity,
      recv_timeout: :infinity
    )
  end

  @impl true
  def post!(url, body, headers), do: HTTPoison.post!(url, body, headers)

  @impl true
  def get!(url, headers), do: HTTPoison.get!(url, headers)

  @impl true
  def get(url, headers), do: HTTPoison.get(url, headers)

  @impl true
  def exists?(path), do: File.exists?(path)

  @impl true
  def fetch_env(app, entry), do: Application.fetch_env(app, entry)

  @impl true
  def puts(device \\ :stdio, data), do: IO.puts(device, data)
end
