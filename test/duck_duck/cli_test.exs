defmodule DuckDuck.CLITest do
  use ExUnit.Case

  alias DuckDuck.CLI

  describe "parsing" do
    test "the yes flag" do
      assert CLI.parse!(["--yes"]) == %{yes: true}
    end

    test "the tag flag" do
      assert CLI.parse!(["--tag", "v220"]) == %{tag: "v220"}
    end

    test "the path flag" do
      assert CLI.parse!(["--file", "_build/artifact.tar.gz"]) == %{file: "_build/artifact.tar.gz"}
    end

    test "all together now" do
      assert CLI.parse!(["--tag", "v220", "--file", "_build/artifact.tar.gz", "--yes"]) == %{
               yes: true,
               tag: "v220",
               file: "_build/artifact.tar.gz"
             }
    end

    test "all aliases" do
      assert CLI.parse!(["-t", "v220", "-f", "_build/artifact.tar.gz", "-y"]) == %{
               yes: true,
               tag: "v220",
               file: "_build/artifact.tar.gz"
             }
    end
  end
end
