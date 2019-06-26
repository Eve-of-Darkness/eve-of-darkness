defmodule EOD.Web.ClientPacketStream do
  @moduledoc """
  The purpose of this channel is to push a clients packets out so they
  can be inspected / monitored by third party tooling
  """

  use Phoenix.Channel
  alias EOD.Web.ClientContext
  require Logger

  def join("clients-packets:" <> account_name, _payload, socket) do
    case ClientContext.get_client_by_account_name(account_name) do
      {:ok, %{pid: pid}} ->
        ClientContext.subcribe_to_packet_inspection(pid)
        {:ok, socket}

      error ->
        Logger.error("Error Joining ClientPacketStream:#{account_name} [#{inspect(error)}]")
        {:error, "#{inspect(error)}"}
    end
  end

  # Packet info forwarded by SimpleSubscription
  def handle_info({:packet_inspection, dir, data}, socket) do
    push(socket, "packet_traffic", %{dir: dir, data: "#{inspect(data.data)}"})
    {:noreply, socket}
  end
end
