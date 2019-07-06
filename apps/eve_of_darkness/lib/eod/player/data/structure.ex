defmodule EOD.Player.Data.Structure do
  @moduledoc """
  This is the actual container for housing all of the data modules
  that are defined for a player.  Because the struct is finalized
  at compile time this portion is a little hard to get a birds eye
  view of; but essentially it's keys and default values are set
  from the `__key__` and `__default__` implemented for the data
  behaviour
  """

  alias EOD.Player
  alias __MODULE__, as: Structure

  @data_modules [
    Player.Encumberance,
    Player.Inventory,
    Player.LivingStats,
    Player.Location,
    Player.Speed
  ]

  defstruct for module <- @data_modules, do: {module.__key__, module.__default__}

  @doc """
  Given a player structure, and optional list of data modules, the
  struct is loaded with data and returned.
  """
  def new(%Player{} = player, modules \\ @data_modules) do
    data =
      Enum.map(modules, fn module ->
        {:ok, data} = module.init(player)
        {module.__key__, data}
      end)

    struct(Structure, data)
  end
end
