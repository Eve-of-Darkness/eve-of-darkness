defmodule EOD.Web.ClientDetailChannel do
  @moduledoc """
  The purpose of this channel is provide direct interaction with a live client,
  mostly to push changes and get information on state changes.
  """

  use Phoenix.Channel
  alias EOD.Web.ClientContext
  require Logger

  def join("clients:" <> account_name, _payload, socket) do
    case ClientContext.get_client_by_account_name(account_name) do
      {:ok, %{pid: pid} = client} ->
        Process.monitor(pid)

        {:ok,
         socket
         |> assign(:client_pid, pid)
         |> assign(:client, client)
         |> schedule_next_client_update(1)
         |> assign(:client_details, client)}

      {:error, reason} ->
        {:error, "#{reason}"}
    end
  end

  def handle_info(:send_client_updates, socket) do
    details =
      socket.assigns[:client]
      |> EOD.Web.ClientView.client_info()

    socket = schedule_next_client_update(socket, 1000)

    if socket.assigns[:client_details] == details do
      {:noreply, socket}
    else
      push(socket, "client_changed", details)
      {:noreply, assign(socket, :client_details, details)}
    end
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, socket) do
    if socket.assigns[:client_pid] == pid do
      {:noreply, cancel_next_client_update(socket)}
    else
      {:noreply, socket}
    end
  end

  defp schedule_next_client_update(socket, time_in_ms) do
    ref = Process.send_after(self(), :send_client_updates, time_in_ms)
    assign(socket, :update_timer, ref)
  end

  defp cancel_next_client_update(socket) do
    Process.cancel_timer(socket.assigns[:update_timer])
    details = socket.assigns[:client_details]
    push(socket, "client_changed", put_in(details.is_running, false))
    socket
  end
end
