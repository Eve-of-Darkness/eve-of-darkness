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
    #{inspect_data(packet.data)}
    }
    """
  end

  defp inspect_data(data) when is_binary(data) do
    EOD.Binary.readable_data_binary(data, "    ")
  end

  defp inspect_data(data) do
    "    #{inspect(data)}"
  end

  defp packet_id(id) when is_nil(id), do: "nil"
  defp packet_id(id) when is_atom(id), do: id
  defp packet_id(id) when is_integer(id), do: "0x" <> hex(id)

  defp hex(num) when is_integer(num), do: Base.encode16(<<num::8>>)
  defp hex(byte) when byte_size(byte) == 1, do: Base.encode16(byte)
  defp hex(nil), do: "  "
end
