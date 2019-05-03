defmodule EOD.Web.ClientView do
  alias EOD.Client

  def render("index.json", %{clients: clients}) do
    %{data: Enum.map(clients, &client_info/1)}
  end

  defp client_info(%{account_name: name, pid: pid}) do
    state = Client.get_state(pid)

    %{account_name: name, ip_address: ip_address(state), started_at: started_at(state)}
  end

  defp ip_address(%{tcp_socket: %{socket: socket}}) do
    case :inet.peername(socket) do
      {:ok, {ip_address, _port}} ->
        :inet.ntoa(ip_address) |> IO.iodata_to_binary()

      _ ->
        "unknown"
    end
  end

  defp started_at(%{started_at: datetime = %DateTime{}}) do
    to_string(datetime)
  end

  defp started_at(_) do
    "unknown"
  end
end
