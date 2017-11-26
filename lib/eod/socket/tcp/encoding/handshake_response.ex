defmodule EOD.Socket.TCP.Encoding.HandshakeResponse do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  def encode(
    code,
    %{major: maj, minor: min, patch: pat, type: type,
      rev: rev, build: build}
  ) do
    {:ok,
      new(code)
      |> write_byte(type)
      |> write_byte(0x00)
      |> write_string("#{maj}.#{min}#{pat}")
      |> write_byte(rev)
      |> write_16(build)}
  end
  def encode(_, _), do: {:error, :init_handshake_encode}
end
