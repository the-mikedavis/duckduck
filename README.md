# DuckDuck [![Coverage Status](https://coveralls.io/repos/github/the-mikedavis/duckduck/badge.svg?branch=master)](https://coveralls.io/github/the-mikedavis/duckduck?branch=master) [![Build Status](https://travis-ci.com/the-mikedavis/duckduck.svg?branch=master)](https://travis-ci.com/the-mikedavis/duckduck) [![Hex Version](https://img.shields.io/hexpm/v/duckduck.svg)](https://hex.pm/packages/duckduck)

DuckDuck is a mix task that uploads Distillery releases to GitHub. This is
useful for CI/CD pipelines that pull directly from GitHub releases. You can get
travis or circle-ci to do it for you, but in some projects (like if you use Elm
or have large brunch builds,) the VMs from travis or circle are too small.

Think of Duckduck as a ~better version of~ alternative to
[edeliver](https://github.com/edeliver/edeliver).

To see a project that actually uses duckduck, check out
[doc_gen](https://github.com/the-mikedavis/doc_gen). DocGen uses elm in the
front end, and I can't get that to build on travis.

## Setup

Couple prerequisites for using duckduck:

<details>
<summary><b>Create a GitHub API Token</b></summary>
<br>

Click on your icon in the top right and go to `Settings`. Go into `Developer
Settings`. You're a real hacker now. Click `Personal Access Tokens > Generate
new token`. Sign in.

Write something memorable in the token description, like
`fossilized geese`. Check the box named `repo`, giving access to all the
children `repo:status`, `repo_deployment`, `public_repo`, and `repo:invite`.
Don't check those individually and leave `repo` unchecked though. You'll need
full repo access to upload artifacts.
</details>

<details>
<summary><b>Setup your Config Files for DuckDuck</b></summary>
<br>
DuckDuck needs to know some things about your GitHub. Setup a block like this
in `config/config.exs`. Or if you're fancy, you can setup different configs
for uploading releases in each environment (e.g. `config/dev.exs`).

```elixir
config :duckduck,
  owner: "the-mikedavis",
  repo: "duckduck",
  token_file: "~/.goose_api_token" # this is the default value if omitted
```

Here `owner` is the repo owner and `repo` is the repo name as GitHub knows it.
I.e. if your repo url is `https://github.com/<owner>/<repo>`, use those.

Instead of using a `token_file`, you can use the `api_token: "MY_KEY"` key.
Please don't put your GitHub API Token in plaintext in a public repo. If you're
gonna use `api_token`, please use an environment variable at least:

```elixir
config :duckduck,
  owner: "the-mikedavis",
  repo: "duckduck",
  api_token: System.get_env("GOOSE_API_TOKEN")
```
</details>

## Usage

First, you have to make a tag for the release and upload that to GitHub.

```
$ git tag -a v25 -m "Wow already v25!"
$ git push v25
```

(If you have a phoenix project, do the assets thing

```
$ cd assets; ./node_modules/.bin/webpack -p; cd .. # OR
$ cd assets; ./node_modules/.bin/brunch b -p; cd ..
$ MIX_ENV=prod mix phx.digest
```

)

Then make a distillery release with your new code.

```
$ MIX_ENV=prod mix release --env=prod
```

Then use duckduck to upload the release artifact that you just generated.

```
$ MIX_ENV=prod mix goose
```

*N.B.*

- the `MIX_ENV` has to be the same as the distillery release
  - this allows you to upload dev releases, if that's your kinda thing
- you must configure releases to be named similarly to the git tag
  - [example distillery config](https://github.com/the-mikedavis/doc_gen/blob/master/rel/config.exs#L53-L58)
  - the matching is done with globbing `_build/#{Mix.env()}/rel/#{app_name}/releases/#{tag}*/#{app_name}.tar.gz`

## Flags

- `--tag <tag>` or `-t <tag>`: specify the tag you want to upload
- `--file <path>` or `-f <path>`: specify the file you want to upload
- `--yes` or `-y`: don't ask for confirmation; useful for running non-interactively

## A Useful Alias

Making aliases is pretty cool. Here's an alias that does it all:

```elixir
# mix.exs
defmodule MyApp.Mixfile do
  use Mix.Project

  def project do
    [
      ...
      aliases: aliases(),
      preferred_cli_env: [
        build_and_upload: :prod,
        goose: :prod
      ],
      ...
    ]
  end

  ...

  defp aliases do
    [
      build_and_upload: [&build_assets/1, "phx.digest", "release", "goose"]
    ]
  end

  # If you use brunch
  defp build_assets(_) do
    assets_path = Path.join(System.cwd!(), "assets")

    assets_path
    |> Path.join("node_modules/.bin/brunch")
    |> System.cmd(["build", "--production"], cd: assets_path)
  end

  # If you use webpack
  defp build_assets(_) do
    assets_path = Path.join(System.cwd!(), "assets")

    assets_path
    |> Path.join("node_modules/.bin/webpack")
    |> System.cmd(["--production"], cd: assets_path)
  end
end
```

Now you can write `$ mix build_and_upload` (without `MIX_ENV=prod` wow!) and
it'll build you assets in production, digest them, build a release with
distillery, and upload the tarball to GitHub.

## Installation

```elixir
def deps do
  [
    {:duckduck, "~> 1.0"}
  ]
end
```

## Inspiration

I liked and used [`ghr`](https://github.com/tcnksm/ghr) for a while, but wanted
a native Elixir solution. Installing go is still kinda painful.

## Contributing

Having troubles using duckduck or have ideas? Send me an issue or a PR!
