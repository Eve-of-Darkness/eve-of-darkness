defmodule EOD.Socket.TCP.Encoding.CharacterNameCheck do
  @moduledoc false
  import EOD.Socket.TCP.ClientPacket

  def decode(%{data: data}, id) when byte_size(data) > 27 do
    {:ok, %{id: id, character_name: read_string(data, 28)}}
  end
  def decode(_, _) do
    {:error, :bad_duplicate_name_check}
  end
end
