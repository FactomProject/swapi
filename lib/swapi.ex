defmodule Mix.Tasks.Swapi do
  @moduledoc """
  Task for checking if swagger file represents current api
  """

  use Mix.Task

  def run(args) do
    Mix.Task.run "compile"
    Mix.Task.run "app.start"
    {_, [file | _ ], _} = OptionParser.parse(args)
    s = swagger_paths(file)
    r = routes()
    check_api(s, r)
    check_swagger(s, r)
  end

  def check_api(s, r) do
    case r -- s do
      [] -> IO.puts "All API paths are present in swagger"
      left ->
        IO.puts :stderr, "API paths not represented in swagger:"
        Enum.map(left, fn {p, v} ->
                         IO.puts "#{format_verb(v)} #{format_path(p)}"
                       end)
    end
  end

  def check_swagger(s, r) do
    case s -- r do
      [] -> IO.puts "All swagger paths are present in API"
      left ->
        IO.puts :stderr, "Swagger paths not represented in API:"
        Enum.map(left, fn {p, v} ->
                         IO.puts "#{format_verb(v)} #{format_path(p)}"
                       end)
    end
  end

  defp format_verb(verb), do: verb |> to_string() |> String.upcase
  defp format_path(path), do: "/" <> Enum.join(path, "/")

  defp swagger_paths(filename) do
    s = swagger_file(filename)
    s["paths"]
    |> Enum.flat_map(fn {path, methods} ->
                  Enum.map(methods, fn {name, _} -> {path, name} end)
                end)
    |> Enum.filter(fn {_p, m} -> m != "parameters" end)
    |> Enum.map(fn {p, m} -> {normalize_path(p), String.to_atom(m)} end)
  end

  defp swagger_file(filename) do
    path = File.cwd! |> Path.join(filename)
    YamlElixir.read_from_file path
  end

  defp normalize_path(path) do
    path
    |> String.split("/")
    |> tl
    |> Enum.map(&normalize_param/1)
  end

  defp normalize_param("{" <> param) do
    param = param
            |> String.trim("}")
            |> String.trim
    ":" <> param
  end
  defp normalize_param(param), do: param

  defp routes do
    r = router()
    r.__routes__()
    |> Enum.map(fn r -> {r.path, r.verb} end)
    |> Enum.filter(fn {_p, v} -> v != :patch end)
    |> Enum.map(fn {p, v} -> {normalize_path(p), v} end)
  end

  defp router do
    appname()
    |> namespace()
    |> to_string()
    |> Module.concat("Router")
  end

  defp appname do
    Mix.Project.config |> Keyword.fetch!(:app)
  end

  defp namespace(app) do
    Application.get_env(app, :namespace)
  end

end
