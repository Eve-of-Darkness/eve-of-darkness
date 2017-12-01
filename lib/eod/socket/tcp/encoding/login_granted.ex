defmodule EOD.Socket.TCP.Encoding.LoginGranted do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  def encode(
    code,
    data = %{username: username}
  ) do
    {:ok,
      new(code)
      |> write_pascal_string(username)
      |> write_pascal_string( data[:server_name] || "EOD")
      |> write_byte( data[:server_id] || 0x05)
      |> write_byte( data[:color] || 0x07)
      |> write_string(<<0x00, 0x00>>)}
  end
  def encode(_, _), do: {:error, :login_granted_encode}
end
