defmodule EOD.Socket.TCP.Encoding.CharacterNameCheckReply do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  @valid_checks [:ok, :invalid, :duplicate]

  def encode(
    code, %{character_name: c_name, username: u_name, status: status}
  ) when status in @valid_checks do

    check_byte = case status do
      :ok -> 0x00
      :invalid -> 0x01
      :duplicate -> 0x02
    end

    {:ok,
      new(code)
      |> write_fill_string(c_name, 30)
      |> write_fill_string(u_name, 24)
      |> write_byte(check_byte)
      |> fill_bytes(0x00, 3)}
  end
  def encode(_, _), do: {:error, :bad_name_check_reply}
end
