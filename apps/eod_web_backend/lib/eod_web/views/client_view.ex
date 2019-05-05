defmodule EOD.Web.ClientView do
  alias EOD.Client

  def render("index.json", %{clients: clients}) do
    %{data: Enum.map(clients, &client_info/1)}
  end

  def render("show.json", %{client: client}) do
    %{data: client_info(client)}
  end

  def client_info(%{account_name: name, pid: pid}) do
    state = Client.get_state(pid)

    %{
      account_name: name,
      ip_address: ip_address(state),
      started_at: started_at(state),
      is_running: Process.alive?(pid),
      version: version(state),
      state: state(state),
      selected_realm: realm(state),
      selected_character: selected_character(state)
    }
  end

  defp ip_address(%{tcp_socket: %{socket: socket}}) do
    case :inet.peername(socket) do
      {:ok, {ip_address, _port}} ->
        :inet.ntoa(ip_address) |> IO.iodata_to_binary()

      _ ->
        "unknown"
    end
  end

  defp version(%{version: version}) do
    with %{major: major, minor: minor, patch: patch, rev: rev, build: build} <- version do
      "#{major}.#{minor}#{patch}#{IO.iodata_to_binary([rev])} #{build}"
    else
      _ ->
        "unkown"
    end
  end

  defp state(%{state: state}), do: "#{state}"

  defp realm(%{selected_realm: realm}), do: "#{realm}"

  defp selected_character(%{selected_character: :none}), do: "none"
  defp selected_character(%{selected_character: char}) when is_map(char), do: normalize_char(char)
  defp selected_character(_), do: "unknown"

  defp normalize_char(%{name: name}), do: name

  defp started_at(%{started_at: datetime = %DateTime{}}) do
    to_string(datetime)
  end

  defp started_at(_) do
    "unknown"
  end
end
