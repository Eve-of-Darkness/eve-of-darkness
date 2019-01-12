defmodule EOD.Packet.Field.Enumeration do
  @moduledoc """
  This is a complex field type which allows you to map packet fields to
  a different specific value that makes more sense.
  """
  use EOD.Packet.Field

  def struct_field_pair({{name, type}, opts}) do
    {name, default} = apply(type, :struct_field_pair, [{name, opts}])

    new_default =
      enum_from_opts(opts)
      |> Enum.find(&match?({^default, _}, &1))
      |> elem(1)

    {name, new_default}
  end

  def from_binary_match({{name, type}, opts}) do
    apply(type, :from_binary_match, [{name, opts}])
  end

  def from_binary_struct({{name, _}, _}) do
    quote do
      {unquote(name), unquote(Macro.var(name, nil))}
    end
  end

  def from_binary_process({{name, type}, opts}) do
    processing = List.wrap(apply(type, :from_binary_process, [{name, opts}]))

    matches =
      enum_from_opts(opts)
      |> Enum.map(fn {raw, val} ->
        {:->, [], [[raw], val]}
      end)

    quote do
      unquote_splicing(processing)

      unquote(Macro.var(name, nil)) =
        case unquote(Macro.var(name, nil)) do
          unquote(matches)
        end
    end
  end

  def to_binary_match({{name, type}, opts}) do
    apply(type, :to_binary_match, [{name, opts}])
  end

  def to_binary_process({{name, type}, opts}) do
    processing = List.wrap(apply(type, :to_binary_process, [{name, opts}]))

    matches =
      enum_from_opts(opts)
      |> Enum.map(fn {raw, val} ->
        {:->, [], [[val], raw]}
      end)

    quote do
      unquote(Macro.var(name, nil)) =
        case unquote(Macro.var(name, nil)) do
          unquote(matches)
        end

      unquote_splicing(processing)
    end
  end

  def to_binary_bin({{name, type}, opts}) do
    apply(type, :to_binary_bin, [{name, opts}])
  end

  def size({{name, type}, opts}), do: apply(type, :size, [{name, opts}])

  defp enum_from_opts(opts) do
    Keyword.get(opts, :enum_values, [])
  end
end
