# DuckDuck

DuckDuck is a mix task that uploads Distillery releases to GitHub. This is
useful for CI/CD pipelines that pull directly from GitHub releases. You can get
travis or circle-ci to do it for you, but in some projects (like if you use Elm
or have large brunch builds), the VMs from travis or circle are too small.

To see a project that actually uses duckduck, check out
[doc_gen](https://github.com/the-mikedavis/doc_gen). DocGen uses elm in the
front end, and I can't get that to build on travis.

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
$ MIX_ENV=prod mix goose v25
```

*N.B.*

- the `MIX_ENV` has to be the same as the distillery release
  - this allows you to upload dev releases, if that's your kinda thing
- you must configure releases to be named similarly to the git tag
  - [example distillery config](https://github.com/the-mikedavis/doc_gen/blob/master/rel/config.exs#L53-L58)
  - the matching is done with globbing `/releases/#{tag}*/#{app_name}.tar.gz`

You should probably set this up as an alias in your `mix.exs`. Again, look at
doc_gen.

## Installation

```elixir
def deps do
  [
    {:duckduck, git: "https://github.com/the-mikedavis/duckduck.git"}
  ]
end
```

## Inspiration

I liked and used [GHR](https://github.com/tcnksm/ghr) for a while, but wanted
a native Elixir solution.

## Contributing

Having troubles using duckduck or have ideas? Send me an issue or a PR!
