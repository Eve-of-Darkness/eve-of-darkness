defmodule EOD.Packet.Field.Compound do
  @moduledoc """
  This packet field provides a way for a packet field to be broken down
  and converted into other fields and vice-versa.
  """
  use EOD.Packet.Field

  def struct_field_pair({{_name, _type}, opts}) do
    Keyword.fetch!(opts, :fields)
    |> List.wrap()
    |> Enum.map(fn field ->
      {field[:name], field[:default]}
    end)
  end

  def from_binary_match({{name, type}, opts}) do
    apply(type, :from_binary_match, [{name, opts}])
  end

  def from_binary_struct({{_name, _type}, opts}) do
    field_name_pairs(opts)
  end

  def from_binary_process({{name, type}, opts}) do
    pairs = field_name_pairs(opts)
    processing = List.wrap(apply(type, :from_binary_process, [{name, opts}]))

    quote do
      unquote_splicing(processing)

      %{unquote_splicing(pairs)} =
        compound(:from_binary, unquote(name), unquote(Macro.var(name, nil)))
    end
  end

  def to_binary_match({{_name, _type}, opts}) do
    field_name_pairs(opts)
  end

  def to_binary_bin({{name, type}, opts}) do
    apply(type, :to_binary_bin, [{name, opts}])
  end

  def to_binary_process({{name, type}, opts}) do
    pairs = field_name_pairs(opts)
    processing = List.wrap(apply(type, :to_binary_process, [{name, opts}]))

    quote do
      unquote(Macro.var(name, nil)) =
        compound(:to_binary, unquote(name), %{unquote_splicing(pairs)})

      unquote_splicing(processing)
    end
  end

  def size({{name, type}, opts}), do: apply(type, :size, [{name, opts}])

  defp field_name_pairs(opts) do
    opts[:fields]
    |> Enum.map(fn field ->
      name = field[:name]

      quote do
        {unquote(name), unquote(Macro.var(name, nil))}
      end
    end)
  end
end
