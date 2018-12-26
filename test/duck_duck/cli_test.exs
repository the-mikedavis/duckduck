defmodule DuckDuck.CLITest do
  use ExUnit.Case

  alias DuckDuck.{CLI, DeadDuckError, TestData}
  import Mox
  import ExUnit.CaptureIO

  @effects Application.fetch_env!(:duckduck, :effects_client)

  setup :verify_on_exit!

  setup do
    [
      path: "/root/file.txt",
      tag: "v220"
    ]
  end

  describe "parsing" do
    test "the yes flag" do
      assert CLI.parse!(["--yes"]) == %{yes: true}
    end

    test "the tag flag" do
      assert CLI.parse!(["--tag", "v220"]) == %{tag: "v220"}
    end

    test "the path flag" do
      assert CLI.parse!(["--file", "_build/artifact.tar.gz"]) == %{
               file: "_build/artifact.tar.gz"
             }
    end

    test "all together now" do
      assert CLI.parse!([
               "--tag",
               "v220",
               "--file",
               "_build/artifact.tar.gz",
               "--yes"
             ]) == %{
               yes: true,
               tag: "v220",
               file: "_build/artifact.tar.gz"
             }
    end

    test "all aliases" do
      assert CLI.parse!(["-t", "v220", "-f", "_build/artifact.tar.gz", "-y"]) ==
               %{
                 yes: true,
                 tag: "v220",
                 file: "_build/artifact.tar.gz"
               }
    end
  end

  describe "resolving" do
    test "with both file and opts", c do
      opts = %{file: c.path, tag: c.tag}
      assert CLI.resolve!(opts) == opts

      opts = %{file: c.path, tag: c.tag, yes: true}
      assert CLI.resolve!(opts) == opts
    end

    test "with just a file", c do
      opts = %{file: c.path}

      expect(@effects, :get_tag, fn -> c.tag end)

      assert CLI.resolve!(opts) == Map.put(opts, :tag, c.tag)
    end

    test "with just a tag and only one file exists", c do
      opts = %{tag: c.tag}

      @effects
      |> expect(:release_files, fn _app, _tag, _path -> [c.path] end)
      |> expect(:build_path, fn -> "" end)

      assert CLI.resolve!(opts) == Map.put(opts, :file, c.path)
    end

    test "with just a tag and no files exist (throws error)", c do
      opts = %{tag: c.tag}

      @effects
      |> expect(:release_files, fn _app, _tag, _path -> [] end)
      |> expect(:build_path, fn -> "" end)

      assert_raise(DeadDuckError, fn -> CLI.resolve!(opts) end)
    end

    test "with just a tag and many files exist (throws error)", c do
      opts = %{tag: c.tag}

      @effects
      |> expect(:release_files, fn _app, _tag, _path ->
        [c.path, "a.tar.gz"]
      end)
      |> expect(:build_path, fn -> "" end)

      assert_raise(DeadDuckError, fn -> CLI.resolve!(opts) end)
    end

    test "with no options provided", c do
      filled_opts = %{tag: c.tag, file: c.path}

      @effects
      |> expect(:release_files, fn _app, _tag, _path -> [c.path] end)
      |> expect(:build_path, fn -> "" end)
      |> expect(:get_tag, fn -> c.tag end)

      assert CLI.resolve!(%{}) == filled_opts
    end
  end

  describe "confirmation" do
    test "when the user has passed the yes flag", c do
      opts = %{file: c.path, tag: c.tag, yes: true}

      assert CLI.confirm!(opts) == opts
    end

    test "when the user confirms with 'yes'", c do
      opts = %{file: c.path, tag: c.tag}

      assert capture_io([input: "yes"], fn ->
               assert CLI.confirm!(opts) == Map.put(opts, :yes, true)
             end) =~ "I want to upload"
    end

    test "when the user confirms with '\\n' (newline)", c do
      opts = %{file: c.path, tag: c.tag}

      assert capture_io([input: "\n"], fn ->
               assert CLI.confirm!(opts) == Map.put(opts, :yes, true)
             end) =~ "I want to upload"
    end

    test "when the user rejects with 'no'", c do
      opts = %{file: c.path, tag: c.tag}

      assert_raise(DeadDuckError, fn ->
        capture_io([input: "no"], fn -> CLI.confirm!(opts) end)
      end)
    end
  end

  describe "full run!" do
    test "success", c do
      opts = %{file: c.path, tag: c.tag, yes: true}

      @effects
      |> expect(:start_http_client, fn -> :ok end)
      |> expect(:read_api_token, fn -> "APITOKEN" end)
      |> expect(:get, fn _url, _headers ->
        TestData.token_http_response()
      end)
      |> expect(:get!, fn _url, _headers ->
        TestData.tag_not_release_response()
      end)
      |> expect(:post!, fn _url, _body, _headers ->
        TestData.create_release_from_tag_response()
      end)
      |> expect(:post_file!, fn _url, _path, _headers ->
        TestData.post_file_success()
      end)

      assert capture_io(fn -> CLI.run!(opts) end) =~
               "Release successfully uploaded"
    end

    test "some sort of bad http response for token checking", c do
      opts = %{file: c.path, tag: c.tag, yes: true}

      @effects
      |> expect(:start_http_client, fn -> :ok end)
      |> expect(:read_api_token, fn -> "APITOKEN" end)
      |> expect(:get, fn _url, _headers -> {:error, :reason} end)

      assert_raise(DeadDuckError, fn ->
        capture_io(fn -> CLI.run!(opts) end) =~
          "doesn't think this token is valid"
      end)
    end
  end
end
