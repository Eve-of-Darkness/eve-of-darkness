defmodule EOD.Packet.Field.CString do
  use EOD.Packet.Field
  import EOD.Packet.OptSize

  def struct_field_pair({name, opts}) do
    default = Keyword.get(opts, :default, "")

    unless is_binary(default) do
      raise ArgumentError, "string field :#{name} default must be a string!"
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

  def from_binary_process({name, _}) do
    quote do
      unquote(Macro.var(name, nil)) =
        EOD.Packet.Field.CString.read_string(unquote(Macro.var(name, nil)))
    end
  end

  def to_binary_match(pair), do: from_binary_struct(pair)

  def to_binary_bin({name, opts}) do
    size = string_size_opt(name, opts)

    quote do
      unquote(Macro.var(name, nil)) :: bytes-size(unquote(size))
    end
  end

  def to_binary_process({name, opts}) do
    size = string_size_opt(name, opts)

    quote do
      unquote(Macro.var(name, nil)) =
        String.pad_trailing(unquote(Macro.var(name, nil)), unquote(size), <<0>>)
    end
  end

  def size({name, opts}) do
    case string_size_opt(name, opts) do
      num when is_integer(num) -> num * 8
    end
  end

  @doc """
  Reads a "C Style" string, which is all bytes up until it reaches the null
  terminator of `0x00`
  """
  def read_string(str) do
    do_read_str(str, <<>>)
  end

  defp do_read_str(<<>>, str), do: str
  defp do_read_str(<<0x00::8, _::binary>>, str), do: str
  defp do_read_str(<<char::8, rem::binary>>, str), do: do_read_str(rem, str <> <<char>>)
end
