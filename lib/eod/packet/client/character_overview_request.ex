defmodule EOD.Packet.Client.CharacterOverviewRequest do
  @moduledoc """
  This packet is sent by the client letting the server know what realm
  screen it is on and is asking for a list of characters to display to
  the user and for which realm.

  See:
  """
  use EOD.Packet do
    code 0xFC
    id :char_overview_request

    compound :user_and_realm, :c_string, size: [bytes: 28] do
      field :username, default: ""
      field :realm, default: :none
    end
  end

  defp compound(:from_binary, :user_and_realm, string) do
    with [name,realm] <- String.split(string, "-") do
      %{username: name, realm: realm_from_string(realm)}
    else
      _ -> :error
    end
  end

  defp compound(:to_binary, :user_and_realm, %{username: name, realm: realm}) do
    name <> "-" <> realm_to_string(realm)
  end

  @realms [albion: "S", midgard: "N", hibernia: "H", none: "X"]

  defp realm_to_string(realm),
    do: Enum.find(@realms, &match?({^realm, _}, &1)) |> elem(1)

  defp realm_from_string(realm),
    do: Enum.find(@realms, &match?({_, ^realm}, &1)) |> elem(0)
end
