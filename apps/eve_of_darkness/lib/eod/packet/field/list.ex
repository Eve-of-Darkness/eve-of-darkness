defmodule EOD.Packet.Field.List do
  @moduledoc """
  This is a complex field which allows you to define a list of similiar fields
  under a single key.  In this case the size option declares how many of field
  will be in the packet.
  """
  use EOD.Packet.Field

  def struct_field_pair({{name, [field | _]}, opts}) do
    struct_field_pair({{name, field}, opts})
  end

  def struct_field_pair({{name, field}, opts}) do
    case Keyword.fetch!(opts, :size) do
      size when is_integer(size) ->
        {name, Enum.map(1..size, fn _ -> struct(field) end)}

      :dynamic ->
        {name, []}
    end
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
          unquote(Macro.var(name, nil)) :: bytes - size(unquote(bytes))
        end
    end
  end

  def from_binary_struct({{name, _field}, _opts}) do
    quote do
      {unquote(name), unquote(Macro.var(name, nil))}
    end
  end

  def from_binary_process({{name, field}, opts}) do
    case Keyword.get(opts, :size) do
      size when is_integer(size) ->
        quote do
          unquote(Macro.var(name, nil)) =
            EOD.Packet.Field.List.fixed_list_match(
              unquote(size),
              unquote(field),
              unquote(Macro.var(name, nil)),
              []
            )
        end

      :dynamic ->
        quote do
          unquote(Macro.var(name, nil)) =
            EOD.Packet.Field.List.dynamic_list_match(
              unquote(Macro.var(name, nil)),
              unquote(field),
              []
            )
        end
    end
  end

  def size({{_name, fields}, _}) when is_list(fields), do: :dynamic

  def size({{_name, field}, opts}) do
    case Keyword.fetch!(opts, :size) do
      :dynamic ->
        :dynamic

      size when is_integer(size) ->
        case apply(field, :packet_size, []) do
          int when is_integer(int) ->
            size * int * 8

          _ ->
            :dynamic
        end
    end
  end

  def to_binary_match(pairs), do: from_binary_struct(pairs)

  def to_binary_bin(pairs), do: from_binary_match(pairs)

  def to_binary_process({{name, fields}, _opts}) when is_list(fields) do
    quote do
      unquote(Macro.var(name, nil)) =
        Enum.reduce(unquote(Macro.var(name, nil)), "", fn %{__struct__: field} = struct, bin ->
          {:ok, data} = apply(field, :to_binary, [struct])
          bin <> data
        end)
    end
  end

  def to_binary_process({{name, field}, _opts}) do
    quote do
      unquote(Macro.var(name, nil)) =
        Enum.reduce(unquote(Macro.var(name, nil)), "", fn struct, bin ->
          {:ok, data} = apply(unquote(field), :to_binary, [struct])
          bin <> data
        end)
    end
  end

  def fixed_list_match(0, _, _, list), do: list |> Enum.reverse()

  def fixed_list_match(current, fields, buffer, list) when is_list(fields) do
    {:ok, item, remainder} = first_to_match(fields, buffer)
    fixed_list_match(current - 1, fields, remainder, [item | list])
  end

  def fixed_list_match(current, field, buffer, list) do
    {:ok, item, remainder} = apply(field, :from_binary_substructure, [buffer])
    fixed_list_match(current - 1, field, remainder, [item | list])
  end

  def dynamic_list_match("", _, list), do: list |> Enum.reverse()

  def dynamic_list_match(bin, field, list) do
    {:ok, item, rem} = apply(field, :from_binary_substructure, [bin])
    dynamic_list_match(rem, field, [item | list])
  end

  ## Private Functions

  defp first_to_match([], _), do: {:error, :no_substructure_match}

  defp first_to_match([field | fields], buffer) do
    case apply(field, :from_binary_substructure, [buffer]) do
      {:ok, item, remainder} ->
        {:ok, item, remainder}

      {:error, {:no_match, ^field}} ->
        first_to_match(fields, buffer)
    end
  end
end
