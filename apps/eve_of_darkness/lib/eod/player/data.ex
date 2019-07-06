defmodule EOD.Player.Data do
  @moduledoc """
  There is a lot of information and state related to a player in the
  game.  Further more, this data is sent to the client in specific
  ways which we must simply just accept.  To avoid an extremely hard
  to grok and read state tree this module aims to orchestrate chunks
  of the player GenServer data to focused and specialized modules.
  """
  alias EOD.Player

  @callback init(Player.t()) :: {:ok, Player.t()}
  @callback __key__() :: atom()
  @callback __default__() :: any()

  @doc """
  This module is meant to be "used" in another module that handles
  some of the data associated with a player.  It essentially enforces
  a behaviour on the host module that can be leveraged to build up a
  large data struct at compile time that can be worked with.
  """
  defmacro __using__(key_and_default) do
    key = Keyword.fetch!(key_and_default, :key)
    default = Keyword.get(key_and_default, :default, nil)

    quote do
      @behaviour EOD.Player.Data

      @impl EOD.Player.Data
      @doc false
      def __key__, do: unquote(key)

      @impl EOD.Player.Data
      @doc false
      def __default__, do: unquote(default)

      @impl EOD.Player.Data
      def init(_player), do: {:ok, __default__()}

      defoverridable init: 1
    end
  end
end
