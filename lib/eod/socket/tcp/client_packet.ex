defmodule EOD.Socket.TCP.ClientPacket do
  @moduledoc """
  This is the wrapper for any message that comes from a client.

  Packets that come from a client have seven distinct parts to them
  in the following order as they come from the socket:

    1. `size` - Two byte integer of how many bytes of data are in the packet
    2. `sequence` - Two byte integer of ordering from the client
    3. `session_id` - Two byte field for session
    4. `parameter` - Two bytes (not sure what it's for)
    5. `id` - One byte field to identify the message
    6. `data` - varied byte size of data payload described by the first two bytes
    7. `check` - Two byte integer checksum of the packet
  """

  defstruct id: nil,
            size: 0,
            session_id: 0,
            parameter: 0,
            sequence: 0,
            data: "",
            check: 0

  @doc """
  Converts a TCP binary packet into a `EOD.Socket.TCP.ClientPacket` on success
  with `{:ok, packet}` or fails with `{:error, :invalid_tcp_client_packet}`. In
  some cases when there is a large amount of data not all of the data will come
  at once.  If that is the case it will return {:parital, bin, bytes_remaining}.
  This data should be kept until the next hunk of data comes in and appended to
  the bin until you have the size needed.
  """
  def from_binary(<<size::16, seq::16, sess::16, param::16, id::16, data::bytes-size(size), check::16>>) do
    {:ok, %__MODULE__{
      id: id, size: size, session_id: sess, parameter: param, sequence: seq, data: data, check: check}}
  end
  def from_binary(<<size::16, _::bytes-size(8), remaining::binary>>=bin)
  when size > byte_size(remaining) - 2 do
    {:partial, bin, size - byte_size(remaining) + 2}
  end
  def from_binary(bin) when is_binary(bin) do
    require Logger
    Logger.error "Invalid TCP Packet: #{inspect bin}"
    {:error, :invalid_tcp_client_packet}
  end

  @doc """
  Reads a null terminated string up to the maximum length
  """
  def read_string(%{data: data}, len), do: read_string(data, 0, len)
  def read_string(data, len), do: read_string(data, 0, len)

  @doc """
  Reads a null terminated string starting at a certain position up to
  a maximum length
  """
  def read_string(%{data: data}, start, len) do
    read_string(data, start, len)
  end
  def read_string(data, start, len) do
    <<_::bytes-size(start), str::bytes-size(len), _::binary>> = data
    do_read_str(str, <<>>)
  end

  defp do_read_str(<<>>, str), do: str
  defp do_read_str(<<0x00::8, _::binary>>, str), do: str
  defp do_read_str(<<char::8, rem::binary>>, str), do: do_read_str(rem, str <> <<char>>)
end
