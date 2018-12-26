defmodule DuckDuckTest do
  use ExUnit.Case

  import Mox
  import ExUnit.CaptureIO
  alias DuckDuck, as: DD

  @effects Application.fetch_env!(:duckduck, :effects_client)

  # pretty smash and grab job here; just string building
  describe "building URLs" do
    setup do
      [
        owner: "the-mikedavis",
        repo: "duckduck",
        tag: "v220",
        repos_url: "https://api.github.com/repos"
      ]
    end

    test "token check", c do
      assert DD.build_token_check_url(c.owner, c.repo) ==
               "#{c.repos_url}/#{c.owner}/#{c.repo}"
    end

    test "tags", c do
      assert DD.build_tags_url(c.owner, c.repo, c.tag) ==
               "#{c.repos_url}/#{c.owner}/#{c.repo}/releases/tags/#{c.tag}"
    end

    test "asset upload", _c do
      assert DD.build_upload_asset_url("/upload", "_build/d.tar.gz") ==
               "/upload?name=d.tar.gz"
    end

    test "release creation", c do
      assert DD.build_release_creation_url(c.owner, c.repo) ==
               "#{c.repos_url}/#{c.owner}/#{c.repo}/releases"
    end
  end

  test "auth header building" do
    assert DD.auth_header("MYSUPERSECRETTOKEN") ==
             [{"Authorization", "token MYSUPERSECRETTOKEN"}]
  end

  test "building a failure error" do
    assert_raise(DD.DeadDuckError, fn ->
      DD.fail("Ack I totally didn't expect this!!")
    end)
  end

  describe "logging" do
    setup do
      [str: "hello world"]
    end

    test "success is green", c do
      assert capture_io(fn ->
               DD.puts_success(c.str)
             end) =~ "\e[32m" <> c.str
    end

    test "failure is red", c do
      assert capture_io(fn ->
               DD.puts_failure(c.str)
             end) =~ "\e[31m" <> c.str
    end
  end

  # update this once I can tell how we're supposed to know if it's valid or not
  test "token checking" do
    expect(@effects, :get, fn _url, _headers ->
      DD.TestData.token_http_response()
    end)

    assert DD.valid_token?("TOKEN", "the-mikedavis", "duckduck")
  end

  test "finding the upload url" do
    @effects
    |> expect(:get!, fn _url, _headers ->
      DD.TestData.http_upload_url_response()
    end)

    assert DD.find_upload_url("TOKEN", "the-mikedavis", "duckduck", "v220") ==
             "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14504222/assets"
  end

  test "creating a release from a tag" do
    @effects
    |> expect(:post!, fn _url, _body, _headers ->
      DD.TestData.create_release_from_tag_response()
    end)

    assert DD.create_release_from_tag(
             "TOKEN",
             "the-mikedavis",
             "duckduck",
             "v220"
           ) ==
             "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14702417/assets{?name,label}"
  end

  test "finding the upload url and creating a release from a tag" do
    @effects
    |> expect(:get!, fn _url, _headers ->
      DD.TestData.tag_not_release_response()
    end)
    |> expect(:post!, fn _url, _body, _headers ->
      DD.TestData.create_release_from_tag_response()
    end)

    assert DD.find_upload_url("TOKEN", "the-mikedavis", "doc_gen", "v28") ==
             "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14702417/assets"
  end

  test "uploading" do
    @effects
    |> expect(:post_file!, fn _url, _path, _headers ->
      DD.TestData.post_file_success()
    end)

    assert capture_io(fn -> DD.upload("/root/a.tar.gz", "TOKEN", "url") end) =~
             "Release successfully uploaded"
  end

  describe "capturing upload errors" do
    test "with a bad token" do
      assert capture_io(fn ->
               DD.TestData.post_file_bad_token()
               |> response_json()
               |> DD.good_upload?()
             end) =~ "Check your token"
    end

    test "with the upload already existing" do
      assert capture_io(fn ->
               DD.TestData.post_file_already_exists_response()
               |> response_json()
               |> DD.good_upload?()
             end) =~ "there's already a release artifact"
    end
  end

  defp response_json(response) do
    response
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
