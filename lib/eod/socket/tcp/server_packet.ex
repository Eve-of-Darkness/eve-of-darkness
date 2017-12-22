defmodule EOD.Socket.TCP.ServerPacket do
  @moduledoc """
  This is the wrapper for any message that goes to the client and includes
  functions to write data to a freshly created packet.  When working with
  a `ServerPacket` think of writing a buffer to be sent to the client.
  """

  defstruct code: nil,
            data: []

  @doc """
  Given an 8bit integer as the code ID for the server packet, this creates
  a packet you can work with which can then be understood by the
  `EOD.Socket.TCP.GameSocket`
  """
  def new(code), do: %__MODULE__{code: code}

  @doc """
  Appends a byte or 8bit integer as a byte to the data buffer
  """
  def write_byte(packet, <<byte::8>>), do: append_data(packet, byte)
  def write_byte(packet, int) when is_integer(int) and int in 0..255,
    do: append_data(packet, int)

  @doc """
  Writes a string to the end of the buffer, this also works with binaries
  """
  def write_string(packet, string) when is_binary(string) do
    append_data(packet, string)
  end

  @doc """
  Writes a string but limiters the max size of the string to a given length
  """
  def write_string(packet, string, maxlen) when byte_size(string) > maxlen,
    do: packet |> append_data(binary_part(string, 0, maxlen))
  def write_string(packet, string, _), do: write_string(packet, string)

  @doc """
  Coverts a packet to IO list; which is a very efficient way to send data to
  an IO device such as a TCP socket
  """
  def to_iolist(packet) do
    {:ok,
      [<<IO.iodata_length(packet.data)::16>>, packet.code, packet.data]}
  end

  @doc """
  Given a two byte binary or a 16bit integer, this will append it to the buffer
  """
  def write_16(packet, <<_::16>> = data), do: append_data(packet, data)
  def write_16(packet, int) when is_integer(int) and int in 0..65_535,
    do: append_data(packet, <<int::16>>)

  @doc """
  Given an two byte binary or 16bit integer, this appends the little endian
  version of it to the buffer, ie: `<<1, 0>>` becomes `<<1, 0>>`
  """
  def write_little_16(packet, <<num::little-integer-size(16)>>),
    do: append_data(packet, <<num::16>>)
  def write_little_16(packet, int) when is_integer(int) and int in 0..65_535,
    do: write_little_16(packet, <<int::16>>)

  @doc """
  Same as `write_16`, but uses 32bit (4 bytes) for an integer given
  """
  def write_32(packet, <<_::32>> = data), do: append_data(packet, data)
  def write_32(packet, int) when is_integer(int) and int in 0..4_294_967_295,
    do: append_data(packet, <<int::32>>)

  @doc """
  Writes a pascal style string using a single byte size header to the buffer
  """
  def write_pascal_string(packet, string) when is_binary(string) do
    packet
    |> write_byte(byte_size(string))
    |> write_string(string)
  end

  @doc """
  Writes a string to the buffer of max length.  The excess length is filled
  with 0x00 bytes
  """
  def write_fill_string(packet, str, len) when byte_size(str) >= len do
    write_string(packet, str, len)
  end
  def write_fill_string(packet, str, len) do
    packet
    |> write_string(str)
    |> fill_bytes(0x00, len - byte_size(str))
  end

  @doc """
  Adds the specified byte to the buffer a certain amount of times
  """
  def fill_bytes(packet, _, 0), do: packet
  def fill_bytes(packet, byte, 1), do: write_byte(packet, byte)
  def fill_bytes(packet, byte, amount) when is_integer(amount) and amount > 1 do
    Enum.reduce(1..amount, packet, fn _, pak -> write_byte(pak, byte) end)
  end

  defp append_data(%{data: data} = packet, payload) do
    %{packet | data: [data, payload]}
  end
end
