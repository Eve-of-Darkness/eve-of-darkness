defmodule EOD.Web.ClientDetailChannel do
  @moduledoc """
  The purpose of this channel is provide direct interaction with a live client,
  mostly to push changes and get information on state changes.
  """

  use Phoenix.Channel
  alias EOD.Web.ClientContext
  alias EOD.Client

  @default_client_details %{
    version: %{},
    session_id: nil,
    state: :unknown,
    selected_realm: :none,
    selected_character: :none,
    characters: []
  }
  @client_keys Map.keys(@default_client_details)

  def join("clients:" <> account_name, _payload, socket) do
    case ClientContext.get_client_by_account_name(account_name) do
      {:ok, pid} ->
        Process.monitor(pid)

        {:ok,
         socket
         |> assign(:client_pid, pid)
         |> schedule_next_client_update(1)
         |> assign(:client_details, @default_client_details)}

      {:error, reason} ->
        {:error, "#{reason}"}
    end
  end

  def handle_info(:send_client_updates, socket) do
    details =
      socket.assigns[:client_pid]
      |> Client.get_state()
      |> Map.take(@client_keys)
      |> normalize_characters()
      |> normalize_selected_character()

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

  defp normalize_characters(%{characters: characters} = details) do
    Map.put(details, :characters, Enum.map(characters, & &1.name))
  end

  defp normalize_selected_character(%{selected_character: :none} = details) do
    details
  end

  defp normalize_selected_character(%{selected_character: char} = details) do
    Map.put(details, :selected_character, char.name)
  end

  defp schedule_next_client_update(socket, time_in_ms) do
    ref = Process.send_after(self(), :send_client_updates, time_in_ms)
    assign(socket, :update_timer, ref)
  end

  defp cancel_next_client_update(socket) do
    Process.cancel_timer(socket.assigns[:update_timer])
    socket
  end
end
