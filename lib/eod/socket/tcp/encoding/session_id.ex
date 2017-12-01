defmodule EOD.Socket.TCP.Encoding.SessionId do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  def encode(code, %{session_id: session_id}) do
    {:ok,
      new(code)
      |> write_little_16(session_id)}
  end
  def encode(_, _), do: {:error, :session_id_encode}
end
