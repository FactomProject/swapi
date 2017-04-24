# Swapi

Tool for checking consistency between swagger file and routes in phoenix
application.
Use only with phoenix framework.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `swapi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:swapi, "~> 0.1.0", only: :dev}]
end
```
Otherwise please add it with `git:` directive:

```elixir
def deps do
     {:swapi, git: "git@github.com:FactomProject/swapi.git", only: :dev},
end
```

## How to use it

```elixir
mix swapi swagger.yaml
```

where `swagger.yaml` is a swagger specification file.

### Uniform parameters in paths

Sometimes paths in swagger file and routes are consistent but because
documentation, and developer convenience could differ parameters have different
names, like: `/users/:user_id` vs. `/users/:id`. You may use `--uniform` option
which will change given path parameters to `:param1`, `:param2` etc.

```elixir
mix swapi swagger.yaml --uniform
```

This way you can still check if documentation and routes are consistent but
preserve naming (which is hard).

## Misc

Right now `swapi` omits `PATCH` methods, as phoenix generates those and `PUT`
methods with `resource` directive for updates, making it redundant.
