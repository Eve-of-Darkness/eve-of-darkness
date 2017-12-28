defmodule EOD.Player do
  @moduledoc """
  Represents an in-game presence for an account.  This is a GenServer that is in
  more ways responsible with the back and forth interactions between the client
  and the rest of the game world and is for holding the state of the character
  currently being controlled via a client.
  """

  use GenServer
  alias EOD.Repo.Character
  alias __MODULE__, as: Player

  defstruct character: %Character{},
            client: nil

  def start_link(%Character{} = character, opts \\ []) do
    client = Keyword.get(opts, :client, self())
    GenServer.start_link(
      Player,
      %Player{character: character, client: client},
      opts)
  end
end
