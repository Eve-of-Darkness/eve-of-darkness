defmodule EOD.Socket.TCP.Encoding.HandshakeRequest do
  @moduledoc false

  def decode(packet, id) do
    with <<addons::4, type::4, major::8, minor::8, patch::8, rev::8, build::16>> <- packet.data do
      {:ok,
        %{id: id,
          addons: addons,
          type: type,
          major: major,
          minor: minor,
          patch: patch,
          rev: rev,
          build: build}}
    else
      _ ->
        {:error, :invalid_handshake_gamepacket}
    end
  end
end
