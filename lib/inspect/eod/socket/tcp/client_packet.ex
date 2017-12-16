defimpl Inspect, for: EOD.Socket.TCP.ClientPacket do
  @moduledoc """
  You're going to see a lot of these from the game client.  This inspection makes it
  a lot easier to look at the data and figure out what is going on.
  """
  def inspect(packet, _opts) do
    """
    %EOD.Socket.TcpClientPacket{
      id: #{packet_id(packet.id)}, size: #{packet.size},
      session_id: #{packet.session_id}, parameter: #{packet.parameter},
      sequence: #{packet.sequence}, check: #{packet.check},
      data:
    #{readable_data_binary(packet.data)}
    }
    """
  end

  defp readable_data_binary(data) when is_binary(data) do
    for(<<byte::8 <- data>>, do: byte)
    |> Enum.chunk_every(12, 12, Stream.repeatedly(fn -> nil end))
    |> Enum.map(fn byte_list ->
      "    #{Enum.map(byte_list, &hex/1) |> Enum.join(" ")}  #{Enum.map(byte_list, &ascii/1)}"
    end)
    |> Enum.join("\n")
  end
  defp readable_data_binary(data) when is_map(data) do
    "    #{inspect data}"
  end

  defp packet_id(id) when is_nil(id), do: "nil"
  defp packet_id(id) when is_atom(id), do: id
  defp packet_id(id) when is_integer(id), do: "0x"<>hex(id)

  defp hex(num) when is_integer(num), do: Base.encode16(<<num::8>>)
  defp hex(byte) when byte_size(byte) == 1, do: Base.encode16(byte)
  defp hex(nil), do: "  "

  defp ascii(nil), do: ""
  defp ascii(num) when num in 32..126, do: <<num::8>>
  defp ascii(_), do: "."
end
