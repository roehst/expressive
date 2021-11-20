defmodule Mix.Tasks.New.Module do
  use Mix.Task

  @shortdoc "Creates a new module"
  @moduledoc """
  Creates a module in a new file.

  Usage:
    mix new.module module_name

  Example:
    `mix new.module Foo.Bar.Zaz` creates a file in `lib/Foo/Bar/Zaz.ex`.
  """

  @doc """
  Translates a module name from a string to a path.

  iex> module_name = "Mix.Tasks.Check"
  iex> module_path = #{__MODULE__}.path_from_module_name(module_name)
  ^module_path = "lib/mix/tasks/check.ex"
  """
  def path_from_module_name(module_name) when is_binary(module_name),
    do:
      module_name
      |> String.split(".")
      |> Enum.map(&Macro.underscore/1)
      |> dupe()
      |> both(&list_init/1, &list_last/1)
      |> both(&Enum.join(&1, "/"), & &1)
      |> both(&("lib/" <> &1), &("/" <> &1 <> ".ex"))
      |> merge(&Kernel.<>/2)

  @spec dupe(any()) :: {any(), any()}
  @doc """
  iex> #{__MODULE__}.dupe(1)
  {1, 1}
  """
  def dupe(x), do: {x, x}

  @spec flip({any(), any()}) :: {any(), any()}
  @doc """
  iex> #{__MODULE__}.flip({1, 2})
  {2, 1}
  """
  def flip({a, b}), do: {b, a}

  @spec both({term(), term()}, fun(), fun()) :: {term(), term()}
  @doc """
  iex> #{__MODULE__}.both({1, 2}, &(&1 + 2), &(&1 * 2))
  {3, 4}
  """
  def both({x, y}, f, g) when is_function(f) and is_function(g), do: {f.(x), g.(y)}

  @spec merge({term(), term()}, fun()) :: term()
  @doc """
  iex> #{__MODULE__}.merge({1, 2}, &(&1 + &2))
  3
  """
  def merge({x, y}, f) when is_function(f), do: f.(x, y)

  @spec list_init(nonempty_list(term())) :: term()
  @doc """
  iex> #{__MODULE__}.list_init([1, 2, 3])
  [1, 2]
  """
  def list_init([_]), do: []
  def list_init([x | y]), do: [x | list_init(y)]

  @spec list_last(nonempty_list(term())) :: term
  @doc """
  iex> #{__MODULE__}.list_last([1, 2, 3])
  3
  """
  def list_last([x]), do: x
  def list_last([_ | xs]), do: list_last(xs)

  @impl Mix.Task
  def run([module_name]) do
    path = path_from_module_name(module_name)

    IO.puts("Creating module #{module_name} at #{path}")

    File.open(path, [:write], fn f ->
      IO.puts(f, """
      defmodule #{module_name} do

      end
      """)
    end)
  end
end
