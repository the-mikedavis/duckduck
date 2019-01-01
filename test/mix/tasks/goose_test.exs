defmodule Mix.Tasks.GooseTest do
  use ExUnit.Case

  @effects Application.fetch_env!(:duckduck, :effects_client)

  import Mox
  import ExUnit.CaptureIO
  alias Mix.Tasks.Goose
  alias DuckDuck.TestData

  describe "a full run" do
    test "that succeeds" do
      @effects
      |> expect(:start_http_client, fn -> :ok end)
      |> expect(:fetch_env, 2, fn
        _app, :owner -> {:ok, "the-mikedavis"}
        _app, :repo -> {:ok, "duckduck"}
      end)
      |> expect(:get_tag, fn -> "v28" end)
      |> expect(:build_path, fn -> "/root" end)
      |> expect(:release_files, fn _, _, _ -> ["/root/file.tar.gz"] end)
      |> expect(:exists?, 1, fn _path -> true end)
      |> expect(:read_api_token, fn -> {:ok, "token"} end)
      |> expect(:get, fn _url, _headers -> TestData.token_http_response() end)
      |> expect(:get!, fn _url, _headers ->
        TestData.tag_not_release_response()
      end)
      |> expect(:post!, fn _url, _body, _headers ->
        TestData.create_release_from_tag_response()
      end)
      |> expect(:post_file!, fn _url, _path, _headers ->
        TestData.post_file_success()
      end)

      assert capture_io([input: "yes\n"], fn ->
               Goose.run([])
             end) =~ "Release successfully uploaded"
    end

    test "with a filled-out argv" do
      @effects
      |> expect(:start_http_client, fn -> :ok end)
      |> expect(:fetch_env, 2, fn
        _app, :owner -> {:ok, "the-mikedavis"}
        _app, :repo -> {:ok, "duckduck"}
      end)
      |> expect(:exists?, 1, fn _path -> true end)
      |> expect(:read_api_token, fn -> {:ok, "token"} end)
      |> expect(:get, fn _url, _headers -> TestData.token_http_response() end)
      |> expect(:get!, fn _url, _headers ->
        TestData.tag_not_release_response()
      end)
      |> expect(:post!, fn _url, _body, _headers ->
        TestData.create_release_from_tag_response()
      end)
      |> expect(:post_file!, fn _url, _path, _headers ->
        TestData.post_file_success()
      end)

      assert capture_io(fn ->
               Goose.run(["-t", "v28", "-f", "/root/file.tar.gz", "-y"])
             end) =~ "Release successfully uploaded"
    end

    test "when the file doesn't exist" do
      @effects
      |> expect(:start_http_client, fn -> :ok end)
      |> expect(:fetch_env, 2, fn
        _app, :owner -> {:ok, "the-mikedavis"}
        _app, :repo -> {:ok, "duckduck"}
      end)
      |> expect(:exists?, fn _path -> false end)
      |> expect(:puts, fn :stderr, data ->
        assert IO.chardata_to_string(data) =~ "Validation for 'path'"
      end)

      assert catch_exit(
               Goose.run(["-t", "v28", "-f", "/root/file.tar.gz", "-y"])
             ) == :shutdown
    end

    test "when there are too many files" do
      @effects
      |> expect(:start_http_client, fn -> :ok end)
      |> expect(:fetch_env, 2, fn
        _app, :owner -> {:ok, "the-mikedavis"}
        _app, :repo -> {:ok, "duckduck"}
      end)
      |> expect(:get_tag, fn -> "v28" end)
      |> expect(:build_path, fn -> "/root" end)
      |> expect(:release_files, fn _, _, _ ->
        ["v20-rc.tar.gz", "v20.tar.gz"]
      end)
      |> expect(:puts, fn :stderr, data ->
        assert IO.chardata_to_string(data) =~ "too many"
      end)

      assert catch_exit(Goose.run([])) == :shutdown
    end

    test "when there are too few files" do
      @effects
      |> expect(:start_http_client, fn -> :ok end)
      |> expect(:fetch_env, 2, fn
        _app, :owner -> {:ok, "the-mikedavis"}
        _app, :repo -> {:ok, "duckduck"}
      end)
      |> expect(:get_tag, fn -> "v28" end)
      |> expect(:build_path, fn -> "/root" end)
      |> expect(:release_files, fn _, _, _ -> [] end)
      |> expect(:puts, fn :stderr, data ->
        assert IO.chardata_to_string(data) =~ "No local"
      end)

      assert catch_exit(Goose.run([])) == :shutdown
    end

    test "when the api token can't be sourced" do
      token_error = "The token file cannot be found"

      @effects
      |> expect(:start_http_client, fn -> :ok end)
      |> expect(:fetch_env, 2, fn
        _app, :owner -> {:ok, "the-mikedavis"}
        _app, :repo -> {:ok, "duckduck"}
      end)
      |> expect(:get_tag, fn -> "v28" end)
      |> expect(:build_path, fn -> "/root" end)
      |> expect(:release_files, fn _, _, _ -> ["/root/file.tar.gz"] end)
      |> expect(:exists?, 1, fn _path -> true end)
      |> expect(:read_api_token, fn -> {:error, token_error} end)
      |> expect(:puts, fn :stderr, data ->
        assert IO.chardata_to_string(data) =~ token_error
      end)

      assert catch_exit(Goose.run([])) == :shutdown
    end
  end
end
