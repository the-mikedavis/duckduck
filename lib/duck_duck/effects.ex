defmodule DuckDuck.Effects do
  @moduledoc false

  alias Mix.Project

  @no_api_token_msg """
  Couldn't find the API token! Please add a valid GitHub API token either

  - In the default location: `~/.goose_api_token`
  - In a config file like so

  ```
  # config/config.exs
  config :duckduck,
    owner: "the-mikedavis",
    repo: "duck_duck",
    token_file: "~/.duck_duck_token_file" # OR
    api_token: "MY_API_TOKEN"
  ```
  """

  defmodule Behaviour do
    @moduledoc false

    @callback get_tag() :: String.t()
    @callback release_files(atom(), String.t(), Path.t()) :: [Path.t()]
    @callback build_path() :: Path.t()
    @callback read_api_token() :: String.t() | no_return()
    @callback start_http_client() :: :ok
    @callback post_file!(String.t(), Path.t(), [{String.t(), String.t()}]) ::
                %HTTPoison.Response{}
    @callback post!(String.t(), binary(), [{String.t(), String.t()}]) ::
                %HTTPoison.Response{}
    @callback get!(String.t(), [{String.t(), String.t()}]) ::
                %HTTPoison.Response{}
    @callback get(String.t(), [{String.t(), String.t()}]) ::
                {:ok, %HTTPoison.Response{}} | {:error, any()}
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
         false <- File.exists?(token_file) do
      DuckDuck.puts_failure(@no_api_token_msg)
      System.halt(1)
    else
      {:ok, api_token} ->
        api_token

      true ->
        token_file
        |> File.read!()
        |> String.trim()
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
end
