defimpl Inspect, for: EOD.Socket.TCP.ServerPacket do
  def inspect(packet, _opts) do
    {:ok, [<<size::16>>, code, data]} = EOD.Socket.TCP.ServerPacket.to_iolist(packet)

    """
    %EOD.Socket.TCP.ServerPacket{
      id: #{code && "0x" <> hex(code)}, size: #{size}
      data:
    #{data |> IO.iodata_to_binary() |> EOD.Binary.readable_data_binary("    ")}
      }
    """
  end

  defp hex(num) when is_integer(num), do: Base.encode16(<<num::8>>)
  defp hex(byte) when byte_size(byte) == 1, do: Base.encode16(byte)
  defp hex(nil), do: "  "
end
