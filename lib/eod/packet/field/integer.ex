defmodule EOD.Packet.Field.Integer do
  use EOD.Packet.Field
  import EOD.Packet.OptSize

  def struct_field_pair({name, opts}) do
    default = Keyword.get(opts, :default, 0)

    unless is_integer(default) do
      raise ArgumentError, "Integer field :#{name} default must be an integer!"
    end

    {name, default}
  end

  def from_binary_match({name, opts}) do
    size = number_size_opt(name, opts)

    quote do
      unquote(Macro.var(name, nil)) :: unquote(size)
    end
  end

  def from_binary_struct({name, _}) do
    quote do
      {unquote(name), unquote(Macro.var(name, nil))}
    end
  end

  def to_binary_match(pair), do: from_binary_struct(pair)

  def to_binary_bin(pair), do: from_binary_match(pair)

  def size({name, opts}), do: number_size_opt(name, opts)
end
