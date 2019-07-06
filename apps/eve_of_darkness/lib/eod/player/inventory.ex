defmodule EOD.Player.Inventory do
  @moduledoc """
  This module manges the inventory of a player; which is everything the player
  is carrying, is equiped, and in their vault(s).
  """

  use EOD.Player.Data, key: :inventory

  alias EOD.{Player, Repo}
  alias Repo.InventorySlot
  # alias EOD.Packet.Server.InventoryUpdate

  def init(%Player{character: character}) do
    import Ecto.Query, only: [from: 2]

    inventory =
      from(s in InventorySlot, where: s.character_id == ^character.id)
      |> Repo.all()

    {:ok, inventory}
  end
end
