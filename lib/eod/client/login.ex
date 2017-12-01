defmodule EOD.Client.Login do
  alias EOD.{Client, Socket, Repo}
  alias Repo.Account

  @version_keys [:build, :major, :minor, :patch, :rev]

  def handle_packet(client=%Client{state: :unknown}, packet=%{id: :handshake_request}) do
    Socket.send(client.tcp_socket, %{ packet | id: :handshake_response })
    %{ client |
       state: :handshake,
       version: Map.take(packet, @version_keys) }
  end

  def handle_packet(client=%Client{state: :handshake}, packet=%{id: :login_request}) do
    case find_or_create_account(packet) do
      {:ok, account} ->
        with {:ok, session_id} <- Client.SessionManager.register(client.sessions) do
          granted_msg = Map.merge(client.version, %{id: :login_granted, username: packet.username})
          :ok = client.tcp_socket |> Socket.send(granted_msg)
          %{ client | account: account, state: :logged_in, session_id: session_id }
        else
          {:error, :no_session} ->
            invalid_msg = Map.merge(client.version, %{id: :login_denied, reason: :too_many_players_logged_in})
            :ok = client.tcp_socket |> Socket.send(invalid_msg)
            :ok = client.tcp_socket |> Socket.close
            %{ client | state: :bad_login }
        end

      {:error, error} ->
        invalid_msg = Map.merge(client.version, %{id: :login_denied, reason: error})
        :ok = client.tcp_socket |> Socket.send(invalid_msg)
        :ok = client.tcp_socket |> Socket.close
        %{ client | state: :bad_login }
    end
  end

  defp find_or_create_account(%{username: username, password: password}=data) do
    case Account.find_by_username(username) |> Repo.one do
      nil ->
        with {:error, _} <- Account.new(data) |> Repo.insert,
        do: {:error, :account_invalid}

      account ->
        if Account.correct_password?(account, password) do
          {:ok, account}
        else
          {:error, :wrong_password}
        end
    end
  end
end
