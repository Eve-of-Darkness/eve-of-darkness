defmodule EOD.Player do
  @moduledoc """
  Represents an in-game presence for an account.  This is a GenServer that is in
  more ways responsible with the back and forth interactions between the client
  and the rest of the game world and is for holding the state of the character
  currently being controlled via a client.
  """

  use GenServer
  alias EOD.Repo.Character
  alias EOD.Client
  alias __MODULE__, as: Player
  alias Player.{LivingStats, Location}

  defstruct character: %Character{},
            data: %{},
            client: nil

  def start_link(%Character{} = character, opts \\ []) do
    client = Keyword.get(opts, :client, self())

    GenServer.start_link(
      Player,
      %Player{character: character, client: client},
      opts
    )
  end

  def cast_with(pid, module, fun, args \\ []) do
    GenServer.cast(pid, {:cast_with, module, fun, args})
    pid
  end

  # GenServer Callbacks

  def init(state) do
    {:ok, state} = LivingStats.init(state)
    {:ok, state} = Location.init(state)
    {:ok, state}
  end

  def handle_cast({:cast_with, module, fun, args}, state) do
    case apply(module, fun, [state | args]) do
      %Player{} = player ->
        {:noreply, player}

      {:ok, %Player{} = player} ->
        {:noreply, player}
    end
  end

  def send_points_update(%{client: client} = state) do
    # TODO This should send real info in the future
    Client.send_message(client, %EOD.Packet.Server.CharacterPointsUpdate{})
    state
  end
end
