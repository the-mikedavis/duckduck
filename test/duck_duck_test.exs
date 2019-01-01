defmodule DuckDuckTest do
  use ExUnit.Case

  import Mox
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
      assert DD.token_check_url(c.owner, c.repo) ==
               "#{c.repos_url}/#{c.owner}/#{c.repo}"
    end

    test "tags", c do
      assert DD.tags_url(c.owner, c.repo, c.tag) ==
               "#{c.repos_url}/#{c.owner}/#{c.repo}/releases/tags/#{c.tag}"
    end

    test "asset upload", _c do
      assert DD.upload_asset_url("/upload", "_build/d.tar.gz") ==
               "/upload?name=d.tar.gz"
    end

    test "release creation", c do
      assert DD.release_creation_url(c.owner, c.repo) ==
               "#{c.repos_url}/#{c.owner}/#{c.repo}/releases"
    end
  end

  test "auth header building" do
    assert DD.auth_header("MYSUPERSECRETTOKEN") ==
             [{"Authorization", "token MYSUPERSECRETTOKEN"}]
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

    assert :ok = DD.upload("/root/a.tar.gz", "TOKEN", "url")
  end

  describe "capturing upload errors" do
    test "with a bad token" do
      upload_status =
        DD.TestData.post_file_bad_token()
        |> response_json()
        |> DD.good_upload?()

      assert {:error, reason} = upload_status
      assert reason =~ "Check your token"
    end

    test "with the upload already existing" do
      upload_status =
        DD.TestData.post_file_already_exists_response()
        |> response_json()
        |> DD.good_upload?()

      assert {:error, reason} = upload_status
      assert reason =~ "already a release artifact"
    end
  end

  defp response_json(response) do
    response
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
