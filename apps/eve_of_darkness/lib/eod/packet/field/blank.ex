defmodule EOD.Packet.Field.Blank do
  @moduledoc """
  Field to skip over unknown and unused parts of a packet
  """
  use EOD.Packet.Field
  import EOD.Packet.OptSize

  def struct_field_pair(_), do: nil

  def from_binary_match({_, :remaining}) do
    quote do
      _ :: binary
    end
  end

  def from_binary_match({_, opts}) do
    size = number_size_opt(:blank, opts)
    using = Keyword.get(opts, :using, 0)

    if Keyword.get(opts, :match_exactly?, false) do
      quote do
        unquote(using) :: unquote(size)
      end
    else
      quote do
        _ :: unquote(size)
      end
    end
  end

  def from_binary_struct(_), do: nil

  def to_binary_match(_), do: nil

  def to_binary_bin({_, :remaining}), do: nil

  def to_binary_bin({_, opts}) do
    using = Keyword.get(opts, :using, 0)
    size = number_size_opt(:blank, opts)

    quote do
      unquote(using) :: unquote(size)
    end
  end

  def size({_, opts}) do
    number_size_opt(:blank, opts)
  end
end
