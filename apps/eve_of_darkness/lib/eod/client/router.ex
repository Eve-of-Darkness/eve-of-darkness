defmodule EOD.Client.Router do
  @moduledoc """
  This is a simple module designed to route a game packet to
  the packet handler that can process it.  All that's really
  involved here is to ensure all of the packet handlers are
  added to the `@packet_handlers` module attribute.
  """
  alias EOD.Client
  require Logger

  @packet_handlers [
    Client.CharacterSelectPacketHandler,
    Client.ConnectivityPacketHandler,
    Client.LoadPlayerPacketHandler,
    Client.LoginPacketHandler
  ]

  @doc """
  Given a client state and packet, this function routes them to
  the correct packet handler for processing

  See: `EOD.Client.PacketHandler`
  """
  for handler <- @packet_handlers, id <- handler.__handles__() do
    def route(state, %{id: unquote(id)} = packet) do
      unquote(handler).handle_packet(state, packet)
    end
  end

  def route(state, unrouted) do
    Logger.error("No route found for EOD.Client.Router for #{inspect(unrouted)}")
    state
  end
end
