defmodule EOD.Client.LoginPacketHandler do
  alias EOD.{Client, Repo}
  alias Repo.Account

  use Client.PacketHandler

  @version_keys [:build, :major, :minor, :patch, :rev]

  defmacro handles do
    quote do
      [:handshake_request, :login_request]
    end
  end

  def handshake_request(client=%Client{state: :unknown}, packet) do
    client
    |> send_tcp(%{ packet | id: :handshake_response })
    |> change_state(:handshake)
    |> extract_version_to_client(packet)
  end

  def login_request(client=%Client{state: :handshake}, packet) do
    with \
      {:ok, account} <- find_or_create_account(packet),
      {:ok, registered_client} <- register_client_session(client)
    do
      registered_client
      |> set_account(account)
      |> send_tcp(good_login_msg(client, packet))
      |> change_state(:logged_in)
    else
      {:error, error} ->
        client
        |> send_tcp(bad_login_msg(client, error))
        |> disconnect!
        |> change_state(:bad_login)
    end
  end

  defp bad_login_msg(%Client{version: version}, error) do
    Map.merge(version, %{id: :login_denied, reason: error})
  end

  defp good_login_msg(%Client{version: version}, %{username: username}) do
    Map.merge(version, %{id: :login_granted, username: username})
  end

  defp extract_version_to_client(client, packet) do
    %{ client | version: Map.take(packet, @version_keys) }
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
