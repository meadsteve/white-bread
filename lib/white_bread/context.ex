defmodule WhiteBread.Context do

  @steps_to_macro [:given_, :when_, :then_, :and_, :but_]

  @doc false
  defmacro __using__(_opts) do
    quote do
      import WhiteBread.Context

      @string_steps HashDict.new

      # List of tuples {regex, function}
      @regex_steps []

      @before_compile WhiteBread.Context
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def execute_step(%{text: step_text} = step, state) do
        if (Dict.has_key?(@string_steps, step_text)) do
          function = Dict.fetch!(@string_steps, step_text)
          apply(function, [state])
        else
          apply_regex_function(step_text, state)
        end
      end

      defp apply_regex_function(step_text, state) do
        {regex, function} = find_regex_and_function(step_text)
        args = unless Regex.names(regex) == [] do
          captures = WhiteBread.RegexExtension.atom_keyed_named_captures(regex, step_text)

          [state, captures]
        else
          [state]
        end
        apply(function, args)
      end

      defp find_regex_and_function(string) do
        [{regex, function}] = @regex_steps
        |> Stream.filter(fn {regex, _} -> Regex.run(regex, string) end)
        |> Enum.take(1)

        {regex, function}
      end
    end
  end

  for step <- @steps_to_macro do

    defmacro unquote(step)(step_text, do: block) do
      define_block_step(step_text, block)
    end

    defmacro unquote(step)(step_text, step_function) do
      define_function_step(step_text, step_function)
    end
  end

  # This catches regexes (internally these are tuples)
  defp define_block_step(step_regex, block) when is_tuple(step_regex) do
    function_name = regex_to_step_atom(step_regex)
    quote do
      @regex_steps [{unquote(step_regex), &__MODULE__.unquote(function_name)/1} | @regex_steps]
      def unquote(function_name)(state) do
        unquote(block)
        {:ok, state}
      end
    end
  end

  defp define_block_step(step_text, block) do
    function_name = String.to_atom("step_" <> step_text)
    quote do
      @string_steps Dict.put(@string_steps, unquote(step_text), &__MODULE__.unquote(function_name)/1)
      def unquote(function_name)(state) do
        unquote(block)
        {:ok, state}
      end
    end
  end

  # This catches regexes (internally these are tuples)
  defp define_function_step(step_regex, function) when is_tuple(step_regex) do
    function_name = regex_to_step_atom(step_regex)
    quote do
      if Regex.names(unquote(step_regex)) == [] do
        @regex_steps [{unquote(step_regex), &__MODULE__.unquote(function_name)/1} | @regex_steps]
        def unquote(function_name)(state) do
          unquote(function).(state)
        end
      else
        @regex_steps [{unquote(step_regex), &__MODULE__.unquote(function_name)/2} | @regex_steps]
        def unquote(function_name)(state, captures) do
          unquote(function).(state, captures)
        end
      end
    end
  end

  defp define_function_step(step_text, function) do
    function_name = String.to_atom("step_" <> step_text)
    quote do
      @string_steps Dict.put(@string_steps, unquote(step_text), &__MODULE__.unquote(function_name)/1)
      def unquote(function_name)(state) do
        unquote(function).(state)
      end
    end
  end

  defp regex_to_step_atom({:sigil_r, _, [{_, _, [string]}, _]}) do
    String.to_atom("regex_step_" <> string)
  end

end
