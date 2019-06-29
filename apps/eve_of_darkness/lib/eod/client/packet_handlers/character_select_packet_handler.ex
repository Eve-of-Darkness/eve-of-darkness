defmodule EOD.Client.CharacterSelectPacketHandler do
  @moduledoc """
  This module is responsible for handling all requests from the client when
  a user is sitting at the "character select" screen.  It handles the creation,
  deltion, and realm selection process.
  """

  use EOD.Client.PacketHandler
  alias EOD.Repo.Character
  alias EOD.Packet.Server.{AssignSession, Realm, CharacterNameCheckReply}

  handles_packets([
    EOD.Packet.Client.CharacterSelectRequest,
    EOD.Packet.Client.CharacterOverviewRequest,
    EOD.Packet.Client.CharacterNameCheckRequest,
    EOD.Packet.Client.CharacterCrudRequest
  ])

  @doc """
  Before loading into the world, the server needs to know what character the
  user intends to use; this takes the character select request and sets the
  client up with the selected character.
  """
  def char_select_request(client, %{char_name: name}) do
    client
    |> set_selected_character(name)
    |> send_tcp(%AssignSession{session_id: client.session_id})
  end

  @doc """
  Depending on what realm the client selects, this echos back the realm
  they have selected.  If they select any realm that isn't `:none` it
  will also send a character overview, which is a list of all the characters
  they have.
  """
  def char_overview_request(client, packet) do
    client
    |> select_realm(packet.realm)
    |> send_tcp(%Realm{realm: packet.realm})
    |> load_characters
    |> case do
      %{selected_realm: :none} = client ->
        client

      client ->
        client
        |> send_tcp(&char_overview_msg(&1))
    end
  end

  @doc """
  The client calls this when you attempt to create a new character. This
  check runs before the call to create a character happens so there is
  still an opportunity for the name to be a duplicate at the worst.
  """
  def character_name_check(client, %{character_name: name}) do
    status =
      cond do
        Character.invalid_name?(name) -> :invalid
        Character.name_taken?(name) -> :duplicate
        true -> :valid
      end

    client
    |> send_tcp(%CharacterNameCheckReply{
      character_name: name,
      username: client.account.username,
      status: status
    })
  end

  @doc """
  The client sends a crud request for characters.  One of the interesting
  things here is the slot number given is different for each realm.  We
  however do processing on them to keep them all uniform from slot 0-9 no
  matter what realm they are in.
  """
  def char_crud_request(client, %{action: :create} = packet) do
    packet
    |> as_character_params(client)
    |> Character.new()
    |> EOD.Repo.insert!()

    client
    |> load_characters
    |> send_tcp(&char_overview_msg(&1))
  end

  def char_crud_request(client, %{action: :delete} = packet) do
    params = as_character_params(packet, client)

    case Enum.find(client.characters, &(&1.slot == params.slot)) do
      nil ->
        client

      character ->
        EOD.Repo.delete!(character)

        client
        |> load_characters
        |> send_tcp(&char_overview_msg(&1))
    end
  end

  @update_actions [:update_cosmetics, :update_attributes, :update_attributes_and_cosmetics]
  def char_crud_request(client, %{action: action} = packet) when action in @update_actions do
    params = as_character_params(packet, client)

    case Enum.find(client.characters, &(&1.slot == params.slot)) do
      nil ->
        client

      character ->
        Character.changeset(character, params)
        |> EOD.Repo.update!()

        client
        |> load_characters
        |> send_tcp(&char_overview_msg(&1))
    end
  end

  # Private Methods

  defp as_character_params(packet, client) do
    packet
    |> Map.from_struct()
    |> Map.merge(%{account_id: client.account.id})
    |> Map.update!(:slot, &rem(&1, 10))
  end

  defp set_selected_character(client, "noname") do
    %{client | selected_character: :none}
  end

  defp set_selected_character(client, char_name) do
    character = Enum.find(client.characters, &(&1.name == char_name))
    %{client | selected_character: character || :none}
  end

  defp load_characters(%{select_realm: :none} = client) do
    %{client | characters: []}
  end

  defp load_characters(%{selected_realm: realm, account: account} = client) do
    import Ecto.Query, only: [from: 2]

    characters =
      from(
        Character.for_account(account) |> Character.for_realm(realm),
        order_by: [asc: :slot]
      )
      |> EOD.Repo.all()

    %{client | characters: characters}
  end

  defp char_overview_msg(%{characters: chars}) do
    alias EOD.Packet.Server.CharacterOverviewResponse, as: Response

    %Response{
      characters:
        Enum.map(0..9, fn slot ->
          Enum.find(chars, &(&1.slot == slot)) |> as_resp_char
        end)
    }
  end

  defp as_resp_char(nil), do: %EOD.Packet.Server.CharacterOverviewResponse.Empty{}

  defp as_resp_char(char) do
    alias EOD.Packet.Server.CharacterOverviewResponse.Character

    Map.from_struct(char)
    |> Map.drop([:account, :inserted_at, :updated_at, :id, :account_id])
    |> Enum.reduce(%Character{}, fn {k, v}, char -> Map.put(char, k, v) end)
  end
end
