defimpl Inspect, for: EOD.Socket.TCP.ServerPacket do
  def inspect(packet, _opts) do
    {:ok, [<<size::16>>, code, data]} = EOD.Socket.TCP.ServerPacket.to_iolist(packet)

    """
    %EOD.Socket.TCP.ServerPacket{
      id: #{code && "0x" <> hex(code)}, size: #{size}
      data:
    #{data |> IO.iodata_to_binary() |> readable_data_binary}
      }
    """
  end

  defp readable_data_binary(data) do
    for(<<byte::8 <- data>>, do: byte)
    |> Enum.chunk_every(12, 12, Stream.repeatedly(fn -> nil end))
    |> Enum.map(fn byte_list ->
      "    #{Enum.map(byte_list, &hex/1) |> Enum.join(" ")}  #{Enum.map(byte_list, &ascii/1)}"
    end)
    |> Enum.join("\n")
  end

  defp hex(num) when is_integer(num), do: Base.encode16(<<num::8>>)
  defp hex(byte) when byte_size(byte) == 1, do: Base.encode16(byte)
  defp hex(nil), do: "  "

  defp ascii(nil), do: ""
  defp ascii(num) when num in 32..126, do: <<num::8>>
  defp ascii(_), do: "."
end
