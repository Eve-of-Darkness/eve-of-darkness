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
  def write_string(packet, string, maxlen) when is_binary(string) and maxlen > 0,
    do: packet |> append_data(binary_part(string, 0, maxlen))

  @doc """
  Coverts a packet to IO list; which is a very efficient way to send data to
  an IO device such as a TCP socket
  """
  def to_iolist(packet) do
    {:ok,
      [ <<IO.iodata_length(packet.data)::16>>, packet.code, packet.data ]}
  end

  @doc """
  Given a two byte binary or a 16bit integer, this will append it to the buffer
  """
  def write_16(packet, <<_::16>>=data), do: append_data(packet, data)
  def write_16(packet, int) when is_integer(int) and int in 0..65_535,
    do: append_data(packet, <<int::16>>)

  @doc """
  Writes a pascal style string using a single byte size header to the buffer
  """
  def write_pascal_string(packet, string) when is_binary(string) do
    packet
    |> write_byte(byte_size(string))
    |> write_string(string)
  end

  defp append_data(packet=%{data: data}, payload) do
    %{ packet | data: [ data, payload ] }
  end
end
