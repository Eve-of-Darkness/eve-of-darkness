defmodule EOD.Player.Inventory do
  @moduledoc """
  This module manges the inventory of a player; which is everything the player
  is carrying, is equiped, and in their vault(s).
  """

  alias EOD.{Player, Repo}
  alias Repo.InventorySlot
  # alias EOD.Packet.Server.InventoryUpdate

  def init(%Player{} = player) do
    import Ecto.Query, only: [from: 2]

    inventory =
      from(s in InventorySlot, where: s.character_id == ^player.character.id)
      |> Repo.all()

    {:ok, put_in(player.data[:inventory], inventory)}
  end
end
