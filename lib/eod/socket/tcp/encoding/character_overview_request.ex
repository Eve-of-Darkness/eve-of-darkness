defmodule EOD.Socket.TCP.Encoding.CharacterOverviewRequest do
  @moduledoc false
  import EOD.Socket.TCP.ClientPacket
  import String, only: [ends_with?: 2]

  def decode(%{data: data}, id) do
    with <<account_name::bytes-size(24), _::binary>> <- data do
      account = read_string(account_name, 24)

      realm =
        cond do
           account |> ends_with?("-X") -> :none
           account |> ends_with?("-S") -> :albion
           account |> ends_with?("-N") -> :midgard
           account |> ends_with?("-H") -> :hibernia
           true -> :unkown
        end

      {:ok, %{id: id, realm: realm}}
    else
      _ ->
        {:error, :invalid_character_overview_gamepacket}
    end
  end
end
