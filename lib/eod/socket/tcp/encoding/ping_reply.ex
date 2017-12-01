defmodule EOD.Socket.TCP.Encoding.PingReply do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  def encode(code, %{sequence: seq, timestamp: timestamp}) do
    {:ok,
      new(code)
      |> write_32(timestamp)
      |> fill_bytes(0x00, 4)
      |> write_16(seq+1)
      |> fill_bytes(0x00, 6)}
  end
  def encode(_, _), do: {:error, :ping_reply_encode}
end
