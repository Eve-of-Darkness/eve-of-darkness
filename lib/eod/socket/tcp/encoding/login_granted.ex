defmodule EOD.Socket.TCP.Encoding.LoginGranted do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  def encode(
    code,
    data = %{major: major, minor: minor, patch: patch, username: username}
  ) do
    {:ok,
      new(code)
      |> write_byte(0x01)
      |> write_byte(major)
      |> write_byte(minor)
      |> write_byte(patch)
      |> write_byte(0x00)
      |> write_pascal_string(username)
      |> write_pascal_string( data[:server_name] || "EOD")
      |> write_byte( data[:server_id] || 0x0C)
      |> write_byte( data[:color] || 0x01)
      |> write_string(<<0x00, 0x00>>)}
  end
  def encode(_, _), do: {:error, :login_granted_encode}
end
