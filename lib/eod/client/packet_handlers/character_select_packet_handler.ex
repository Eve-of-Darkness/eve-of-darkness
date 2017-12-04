defmodule EOD.Client.CharacterSelectPacketHandler do
  @moduledoc """
  This module is responsible for handling all requests from the client when
  a user is sitting at the "character select" screen.  It handles the creation,
  deltion, and realm selection process.
  """

  use EOD.Client.PacketHandler
  alias EOD.Repo.Character

  defmacro handles do
    quote do: [
      :char_select_request,
      :char_overview_request,
      :character_name_check,
      :char_crud_request]
  end

  @doc """
  This is a fairly mysterious request; it sends a character name but
  not fully sure what it's for.  This request also expects to be given
  a session id so this sends it down to the client.
  """
  def char_select_request(client, _packet) do
    # TODO: Currently blindly just sending session; however, in the future
    # this needs to check :name on the packet for a character
    client |> send_tcp(%{ id: :session_id, session_id: client.session_id })
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
    |> send_tcp(%{id: :realm, realm: packet.realm})
    |> load_characters
    |> case do
      %{selected_realm: :none}=client -> client

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
    status = cond do
      Character.invalid_name?(name) -> :invalid
      Character.name_taken?(name) -> :duplicate
      true -> :ok
    end

    client |> send_tcp(%{
      id: :character_name_check_reply,
      character_name: name,
      username: client.account.username,
      status: status})
  end

  @doc """
  Not fully happy with the protocol that happens betwee the client and
  server; but it is what it is.  The client sends all of the characters
  it knows about in it's slot locations.  You have to use this information
  as well as the `:action` hint to decide what characters to create or
  delete.
  """
  def char_crud_request(client, %{action: :create}=packet) do
    packet.characters
    |> Enum.filter(&(&1.name != ""))
    |> Enum.each(fn char ->
      unless Enum.any?(client.characters, &(&1.slot == char.slot)) do
        Map.merge(char, %{account_id: client.account.id})
        |> Character.new
        |> EOD.Repo.insert
      end
    end)

    client
    |> load_characters
    |> send_tcp(&char_overview_msg(&1))
  end
  def char_crud_request(client, %{action: :delete}=packet) do
    client.characters
    |> Enum.each(fn char ->
      if Enum.any?(packet.characters, &(&1.slot == char.slot && &1.name == "")) do
        EOD.Repo.delete(char)
      end
    end)

    client
    |> load_characters
    |> send_tcp(&char_overview_msg(&1))
  end

  # Private Methods

  defp load_characters(%{select_realm: :none}=client) do
    %{ client | characters: [] }
  end
  defp load_characters(%{selected_realm: realm, account: account}=client) do
    import Ecto.Query, only: [from: 2]

    characters =
      from(
        Character.for_account(account) |> Character.for_realm(realm),
        order_by: [asc: :slot]
      ) |> EOD.Repo.all

    %{ client | characters: characters }
  end

  defp char_overview_msg(%{characters: chars, account: account}) do
    %{id: :char_overview, characters: chars, username: account.username}
  end
end
