defmodule Mix.Tasks.Check do
  require Logger
  use Mix.Task
  @shortdoc "Run all check."

  defp snd({_a, b}), do: b

  defp show_path_and_lines(path, source_code),
    do: IO.puts("File #{path} has #{source_code |> String.split(~r/\n/) |> Enum.count()} lines")

  defp pass_through(x, f) do
    f.(x)
    x
  end

  def run(args) when is_list(args) do
    Enum.each(args, &run/1)
  end

  def run("--lfb") do
    Logger.info("Searching for large function bodies...")
    Enum.each(find_source_code_files(), &run("--lfb", &1))
  end

  def run("--nts"), do: Logger.info("Searching for functions with no typespec...")

  def run(opt), do: Logger.warn("Unknown option: #{opt}")

  def run("--lfb", path),
    do:
      path
      |> File.read!()
      |> pass_through(&show_path_and_lines(path, &1))
      |> Code.string_to_quoted!()
      |> Macro.prewalk([], &lfb/2)
      |> snd
      |> Enum.map(&IO.inspect/1)

  # TODO: Search for large blocks online.
  defp lfb({:def, [line: line], [{name, _, args}, [do: {:__block__, [], body}]]} = ast, acc)
       when is_atom(name),
       do:
         {ast,
          [
            {:lfb,
             {{:name, name}, {:arity, Enum.count(args)}, {:line, line},
              {:expressions, Enum.count(body)}}}
            | acc
          ]}

  defp lfb(ast, acc), do: {ast, acc}

  defp find_source_code_files(), do: File.cwd!() |> Path.join("**/*.ex") |> Path.wildcard()
end
