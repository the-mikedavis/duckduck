defmodule DuckDuck.TransformTest do
  use ExUnit.Case

  alias DuckDuck.TestData
  alias DuckDuck.Transform, as: Trans
  alias DuckDuck.UploadCommand, as: Command
  # alias Ecto.Changeset
  import Mox
  import ExUnit.CaptureIO

  @effects Application.fetch_env!(:duckduck, :effects_client)

  setup :verify_on_exit!

  setup do
    [
      api_token: "token",
      repo: "doc_gen",
      owner: "the-mikedavis",
      tag: "v28",
      path: "/root/file.tar.gz"
    ]
  end

  def change_command(opts \\ %{}), do: Command.changeset(%Command{}, opts)

  describe "parsing" do
    test "the yes flag" do
      assert Trans.parse(["--yes"]).changes == %{accept?: true}
    end

    test "the tag flag" do
      assert Trans.parse(["--tag", "v220"]).changes == %{tag: "v220"}
    end

    test "the path flag" do
      expect(@effects, :exists?, fn _path -> true end)

      assert Trans.parse(["--file", "_build/artifact.tar.gz"]).changes == %{
               path: "_build/artifact.tar.gz"
             }
    end

    test "all together now" do
      expect(@effects, :exists?, fn _path -> true end)

      assert Trans.parse([
               "--tag",
               "v220",
               "--file",
               "_build/artifact.tar.gz",
               "--yes"
             ]).changes == %{
               accept?: true,
               tag: "v220",
               path: "_build/artifact.tar.gz"
             }
    end

    test "all aliases" do
      expect(@effects, :exists?, fn _path -> true end)

      assert Trans.parse(["-t", "v220", "-f", "_build/artifact.tar.gz", "-y"]).changes ==
               %{
                 accept?: true,
                 tag: "v220",
                 path: "_build/artifact.tar.gz"
               }
    end
  end

  describe "owner and repo transformation" do
    setup do
      [owner: "the-mikedavis", repo: "duckduck"]
    end

    test "when the user has nothing", c do
      expect(@effects, :fetch_env, 2, fn
        _app, :owner -> {:ok, c.owner}
        _app, :repo -> {:ok, c.repo}
      end)

      changeset =
        change_command()
        |> Trans.put_owner()
        |> Trans.put_repo()

      assert {:owner, c.owner} in changeset.changes
      assert {:repo, c.repo} in changeset.changes
    end

    test "when they're already there", c do
      changeset =
        change_command(%{owner: c.owner, repo: c.repo})
        |> Trans.put_owner()
        |> Trans.put_repo()

      assert {:owner, c.owner} in changeset.changes
      assert {:repo, c.repo} in changeset.changes
    end

    test "when they're not in the config", c do
      expect(@effects, :fetch_env, 2, fn _, _ -> :error end)

      changeset =
        change_command()
        |> Trans.put_owner()
        |> Trans.put_repo()

      refute {:owner, c.owner} in changeset.changes
      refute {:repo, c.repo} in changeset.changes
    end
  end

  describe "tag transformation" do
    test "when the tag was already in the changeset" do
      changeset = change_command(%{tag: "v220"})

      assert Trans.put_tag(changeset).changes.tag == "v220"
    end

    test "when the tag was NOT already in the changeset" do
      changeset = change_command(%{owner: "the-mikedavis", repo: "duckduck"})

      expect(@effects, :get_tag, fn -> "v220" end)

      assert Trans.put_tag(changeset).changes.tag == "v220"
    end
  end

  describe "path transformation" do
    setup do
      [path: "/root/file.tar.gz"]
    end

    test "when the path was already in the changeset", c do
      expect(@effects, :exists?, fn _path -> true end)

      changeset = change_command(%{path: c.path})

      assert Trans.put_path(changeset).changes.path == c.path
    end

    test "when the path was NOT already in the changeset", c do
      @effects
      |> expect(:exists?, fn _path -> true end)
      |> expect(:build_path, fn -> "/root/" end)
      |> expect(:release_files, fn _, _tag, _path -> [c.path] end)

      changeset = change_command(%{tag: "v220"})

      assert Trans.put_path(changeset).changes.path == c.path
    end

    test "when there are too many files", c do
      @effects
      |> expect(:build_path, fn -> "/root/" end)
      |> expect(:release_files, fn _, _tag, _path -> [c.path, "otherfile"] end)

      changeset =
        %{tag: "v220"}
        |> change_command()
        |> Trans.put_path()

      refute {:path, c.path} in changeset.changes

      assert {:path, {"Found too many local release paths for v220!", []}} in changeset.errors
    end

    test "when there are no files", c do
      @effects
      |> expect(:build_path, fn -> "/root/" end)
      |> expect(:release_files, fn _, _tag, _path -> [] end)

      changeset =
        %{tag: "v220"}
        |> change_command()
        |> Trans.put_path()

      refute {:path, c.path} in changeset.changes

      assert {:path, {"No local release paths found for v220!", []}} in changeset.errors
    end

    test "when the user doesn't have a tag or path" do
      changeset = change_command()
      assert Trans.put_path(changeset) == changeset
    end

    test "when the path does not exist, the validation fails", c do
      expect(@effects, :exists?, fn _path -> false end)

      changeset = change_command(%{path: c.path})

      assert {:path, {"No release files found at #{c.path}", []}} in changeset.errors
    end
  end

  describe "user confirmation transformation" do
    test "when the user has passed the yes flag" do
      changeset = change_command(%{accept?: true})

      assert Trans.put_accept(changeset) == changeset
    end

    test "when the user confirms with 'yes'" do
      expect(@effects, :exists?, 2, fn _path -> true end)

      changeset = change_command(%{tag: "v220", path: "/root/file.tar.gz"})

      capture_io([input: "yes"], fn ->
        assert Trans.put_accept(changeset).changes.accept?
      end)
    end

    test "when the user confirms with '\\n' (newline)" do
      expect(@effects, :exists?, 2, fn _path -> true end)

      changeset = change_command(%{tag: "v220", path: "/root/file.tar.gz"})

      capture_io([input: "\n"], fn ->
        assert Trans.put_accept(changeset).changes.accept?
      end)
    end

    test "when the user rejects with 'no'" do
      expect(@effects, :exists?, 2, fn _path -> true end)

      changeset = change_command(%{tag: "v220", path: "/root/file.tar.gz"})

      capture_io([input: "no"], fn ->
        refute {:accept?, true} in Trans.put_accept(changeset).changes
      end)
    end

    test "when there's not a tag or path" do
      changeset = change_command()

      assert Trans.put_accept(changeset) == changeset
    end
  end

  describe "putting the api_token" do
    test "when the api token is already there" do
      expect(@effects, :get, fn _url, _headers ->
        TestData.token_http_response()
      end)

      changeset =
        change_command(%{
          owner: "the-mikedavis",
          repo: "duckduck",
          api_token: "token"
        })

      assert {:api_token, "token"} in Trans.put_api_token(changeset).changes
    end

    test "when the api token is NOT already there" do
      @effects
      |> expect(:read_api_token, fn -> "token" end)
      |> expect(:get, fn _url, _headers -> TestData.token_http_response() end)

      changeset = change_command(%{owner: "the-mikedavis", repo: "duckduck"})

      assert {:api_token, "token"} in Trans.put_api_token(changeset).changes
    end
  end

  describe "the upload URL transformation" do
    test "when the changeset has all requisite information and the tag is good",
         c do
      @effects
      |> expect(:exists?, 2, fn _path -> true end)
      |> expect(:get, 2, fn _url, _headers -> TestData.token_http_response() end)
      |> expect(:get!, fn _url, _headers ->
        TestData.tag_not_release_response()
      end)
      |> expect(:post!, fn _url, _body, _headers ->
        TestData.create_release_from_tag_response()
      end)

      changeset =
        c
        |> Enum.into(%{})
        |> change_command()
        |> Trans.put_upload_url()

      url = Map.fetch!(changeset.changes, :upload_url)

      assert url =~ "uploads.github.com"
      assert url =~ c.owner
      assert url =~ c.repo
      assert url =~ "releases"
      assert url =~ "assets"
    end

    test "when the changeset is missing something", c do
      changeset =
        %{owner: c.owner, repo: c.repo}
        |> change_command()
        |> Trans.put_upload_url()

      assert [{:upload_url, {upload_error, []}} | _others] = changeset.errors
      assert upload_error =~ "I didn't know at least one of"
    end
  end

  describe "the upload action" do
    test "with an invalid changeset", c do
      expect(@effects, :exists?, fn _path -> false end)

      changeset = change_command(%{owner: c.owner, repo: c.repo, path: c.path})

      refute changeset.valid?

      response =
        changeset
        |> Trans.upload()
        |> IO.ANSI.format(false)
        |> IO.chardata_to_string()

      assert response =~ "Release upload failed."
      assert response =~ "No release files found at"
    end

    test "with a valid changeset", c do
      @effects
      |> expect(:exists?, fn _path -> true end)
      |> expect(:get, fn _url, _headers -> TestData.token_http_response() end)
      |> expect(:post_file!, fn _url, _path, _headers ->
        TestData.post_file_success()
      end)

      changeset =
        c
        |> Enum.into(%{
          upload_url: "https://uploads.github.com/assets",
          accept?: true
        })
        |> change_command()

      assert capture_io(fn ->
               response =
                 changeset
                 |> Trans.upload()
                 |> IO.ANSI.format(false)
                 |> IO.chardata_to_string()

               assert response == "Release successfully uploaded."
             end) =~ "Please wait. Uploading"
    end
  end
end
