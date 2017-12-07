defmodule EOD.Packet.Field.List do
  use EOD.Packet.Field

  def struct_field_pair({{name, field}, opts}) do
    size = Keyword.fetch!(opts, :size)

    {name, Enum.map(1..size, fn _ -> struct(field) end)}
  end

  def from_binary_match({{name, field}, opts}) do
    case size({{name, field}, opts}) do
      :dynamic ->
        quote do
          unquote(Macro.var(name, nil)) :: binary
        end

      size ->
        bytes = div(size, 8)
        quote do
          unquote(Macro.var(name, nil)) :: bytes-size(unquote(bytes))
        end
    end
  end

  def from_binary_struct({{name, _field}, _opts}) do
    quote do
      {unquote(name), unquote(Macro.var(name, nil))}
    end
  end

  def from_binary_process({{name, field}, opts}) do
    size = Keyword.get(opts, :size)

    quote do
      unquote(Macro.var(name, nil)) =
        Enum.reduce(1 .. unquote(size), {[], unquote(Macro.var(name, nil))}, fn _, {col, bin} ->
          {:ok, item, rem} = apply(unquote(field), :from_binary_substructure, [bin])
          {[item|col], rem}
        end)
        |> elem(0)
        |> Enum.reverse
    end
  end

  def size({{_name, field}, opts}) do
    size = Keyword.fetch!(opts, :size)

    case apply(field, :packet_size, []) do
      int when is_integer(int) ->
        size * int * 8
      _ ->
        :dynamic
    end
  end

  def to_binary_match(pairs), do: from_binary_struct(pairs)

  def to_binary_bin(pairs), do: from_binary_match(pairs)

  def to_binary_process({{name, field}, _opts}) do
    #TODO enforce size to binary ?
    quote do
      unquote(Macro.var(name, nil)) =
        Enum.reduce(unquote(Macro.var(name, nil)), "", fn struct, bin ->
          {:ok, data} = apply(unquote(field), :to_binary, [struct])
          bin <> data
        end)
    end
  end
end
