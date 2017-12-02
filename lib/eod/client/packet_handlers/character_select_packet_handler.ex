defmodule EOD.Client.CharacterSelectPacketHandler do
  use EOD.Client.PacketHandler
  alias EOD.Repo.Character

  defmacro handles do
    quote do: [
      :char_select_request,
      :char_overview_request,
      :character_name_check]
  end

  def char_select_request(client, _packet) do
    # TODO: Currently blindly just sending session; however, in the future
    # this needs to check :name on the packet for a character
    client |> send_tcp(%{ id: :session_id, session_id: client.session_id })
  end

  def char_overview_request(client, packet) do
    # TODO: Currently **not** doing any processing on this, just sending blank
    # list of characters for now to get this flow working
    if packet.realm == :none do
      client |> send_tcp(%{id: :realm, realm: :none})
    else
      client
      |> send_tcp(%{id: :char_overview, characters: [], username: client.account.username})
    end
  end

  def character_name_check(client, %{character_name: name}) do
    require Logger
    Logger.warn "Checking name [#{name}]"

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
end
