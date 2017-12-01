defmodule EOD.Socket.TCP.Encoding.CharacterSelectRequest do
  @moduledoc false
  def decode(%{data: data}, id) do
    with <<_::bytes-size(5), charname::bytes-size(28), _::binary>> <- data do
      {:ok, %{id: id, name: read_string(charname)}}
    else
      _ ->
        {:error, :invalid_character_select_gamepacket}
    end
  end

  defp read_string(bytes) when is_binary(bytes), do: do_read_str(bytes, <<>>)

  defp do_read_str(<<>>, str), do: str
  defp do_read_str(<<0x00::8, _::binary>>, str), do: str
  defp do_read_str(<<char::8, rem::binary>>, str), do: do_read_str(rem, str <> <<char>>)
end
