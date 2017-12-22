defmodule EOD.Packet.Field.String do
  @moduledoc """
  A packet field for a standard string.  This isn't used much and great
  care should be taken when using this. It needs to be an exact size
  and relies on you to do any needed padding.
  """
  use EOD.Packet.Field
  import EOD.Packet.OptSize

  def struct_field_pair({name, opts}) do
    default = Keyword.get(opts, :default, "")

    unless is_binary(default) do
      raise ArgumentError, "String field :#{name} default must be a string!"
    end

    {name, default}
  end

  def from_binary_match({name, opts}) do
    size = string_size_opt(name, opts)

    quote do
      unquote(Macro.var(name, nil)) :: bytes-size(unquote(size))
    end
  end

  def from_binary_struct({name, _}) do
    quote do
      {unquote(name), unquote(Macro.var(name, nil))}
    end
  end

  def to_binary_match(pair), do: from_binary_struct(pair)

  def to_binary_bin(pair), do: from_binary_match(pair)

  def size({name, opts}), do: string_size_opt(name, opts) * 8
end
