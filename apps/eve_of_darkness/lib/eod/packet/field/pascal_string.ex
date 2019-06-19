defmodule EOD.Packet.Field.PascalString do
  @moduledoc """
  Pascal string packet field.  This supports an option of `:type` which can be
  either `:big` or `:little`, and defaults to `:big`.  The size of a pascal string
  defines how big the header is for the string size.

  Another option; and somewhat odd that it is needed; is you can optionally specify
  if the pascal string should be null terminated. By default this is false; however,
  if set to true it will pad the string with an `0x00` byte and ensure that the size
  of the string reflects this null termination chacaracter.
  """
  use EOD.Packet.Field
  import EOD.Packet.OptSize

  def struct_field_pair({name, opts}) do
    default = Keyword.get(opts, :default, "")

    unless is_binary(default) do
      raise ArgumentError, "string field :#{name} default must be a string!"
    end

    {name, default}
  end

  def from_binary_process({name, opts}) do
    if Keyword.get(opts, :null_terminated, false) do
      quote do
        unquote(Macro.var(name, nil)) =
          EOD.Packet.Field.CString.read_string(unquote(Macro.var(name, nil)))
      end
    end
  end

  def from_binary_match({name, opts}) do
    size = number_size_opt(name, opts)
    type = Keyword.get(opts, :type, :big)

    unless type in [:big, :little] do
      raise ArgumentError, "Pascal string #{name} can only be of type :big or :little"
    end

    if type == :little && size < 16 do
      raise ArgumentError, "Pascal string #{name} must be at least two bytes if type is :little"
    end

    len = :"#{name}_len__"

    case type do
      :big ->
        quote do
          <<unquote(Macro.var(len, nil))::unquote(size),
            unquote(Macro.var(name, nil))::bytes-size(unquote(Macro.var(len, nil)))>>
        end

      :little ->
        quote do
          <<unquote(Macro.var(len, nil))::little-integer-size(unquote(size)),
            unquote(Macro.var(name, nil))::bytes-size(unquote(Macro.var(len, nil)))>>
        end
    end
  end

  def from_binary_struct({name, _}) do
    quote do
      {unquote(name), unquote(Macro.var(name, nil))}
    end
  end

  def to_binary_match(pair), do: from_binary_struct(pair)

  def size(_), do: :anchored_dynamic

  def to_binary_bin({name, opts}) do
    size = number_size_opt(name, opts)
    type = Keyword.get(opts, :type, :big)
    null = Keyword.get(opts, :null_terminated, false)

    case {type, null} do
      {:big, true} ->
        quote do
          <<byte_size(unquote(Macro.var(name, nil))) + 1::unquote(size),
            unquote(Macro.var(name, nil))::binary, 0::8>>
        end

      {:big, false} ->
        quote do
          <<byte_size(unquote(Macro.var(name, nil)))::unquote(size),
            unquote(Macro.var(name, nil))::binary>>
        end

      {:little, false} ->
        quote do
          <<byte_size(unquote(Macro.var(name, nil)))::little-integer-size(unquote(size)),
            unquote(Macro.var(name, nil))::binary>>
        end

      {:little, true} ->
        quote do
          <<byte_size(unquote(Macro.var(name, nil))) + 1::little-integer-size(unquote(size)),
            unquote(Macro.var(name, nil))::binary, 0::8>>
        end
    end
  end
end
