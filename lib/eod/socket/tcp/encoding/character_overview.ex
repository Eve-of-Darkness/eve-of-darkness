defmodule EOD.Socket.TCP.Encoding.CharacterOverview do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  def encode(
    code,
    %{ characters: _characters, username: name }
  ) do
    # TODO - just sending an empty set for now
    {:ok,
      new(code)
      |> write_fill_string(name, 28)
      |> fill_bytes(0x00, 1970)}
  end
  def encode(_, _), do: {:error, :char_overview_encode}
end
