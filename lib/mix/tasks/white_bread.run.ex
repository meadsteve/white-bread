defmodule Mix.Tasks.WhiteBread.Run do
  use Mix.Task

  alias WhiteBread.CommandLine.SuiteRun

  @shortdoc "Runs all the feature files with WhiteBread"

  @suite_config_option :config
  @default_suite_config "features/config.exs"

  @context_path_option :contexts
  @context_path "features/contexts/"

  def run(argv) do
    {options, arguments, _} = OptionParser.parse(argv)
    start_app(argv)
    failures = run_suite(options, arguments)
    System.at_exit fn _ ->
      if Enum.count(failures) > 0, do: exit({:shutdown, 1})
    end
  end

  defp run_suite(options, _arguments) do
    #suite_config_present?
    SuiteRun.run_suites(
      config_path: config_path(options),
      contexts: contexts_path(options)
    )
  end

  defp suite_config_present?, do: File.exists?(@default_suite_config)

  defp start_app(argv) do
    unless "--no-start" in argv do
      Mix.Task.run "app.start", argv
    end
  end

  defp config_path(options) do
    if Dict.has_key?(options, @suite_config_option) do
      Dict.get(options, @suite_config_option)
    else
      @default_suite_config
    end
  end

  defp contexts_path(options) do
    if Dict.has_key?(options, @context_path_option) do
      Dict.get(options, @context_path_option)
    else
      @context_path
    end
  end

end
