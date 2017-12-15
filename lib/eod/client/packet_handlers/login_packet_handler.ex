defmodule EOD.Client.LoginPacketHandler do
  alias EOD.{Client, Repo}
  alias Repo.Account
  alias EOD.Packet.Server.{HandshakeResponse, LoginGranted, LoginDenied}

  use Client.PacketHandler

  @version_keys [:build, :major, :minor, :patch, :rev]

  defmacro handles do
    quote do
      [:handshake_request, :login_request]
    end
  end

  def handshake_request(client=%Client{state: :unknown}, %{data: data}) do
    client
    |> send_tcp(handshake_response(data))
    |> change_state(:handshake)
    |> extract_version_to_client(data)
  end

  def login_request(client=%Client{state: :handshake}, %{data: data}) do
    with \
      {:ok, account} <- find_or_create_account(data),
      {:ok, registered_client} <- register_client_session(client)
    do
      registered_client
      |> set_account(account)
      |> send_tcp(good_login_msg(data))
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
    %LoginDenied{reason: error, major: version.major, minor: version.minor}
  end

  defp good_login_msg(%{username: username}) do
    %LoginGranted{username: username, server_name: "EOD"}
  end

  defp extract_version_to_client(client, data) do
    %{ client | version: Map.take(data, @version_keys) }
  end

  defp handshake_response(data) do
    %HandshakeResponse{
      type: data.type,
      rev: data.rev,
      build: data.build,
      version: "#{data.major}.#{data.minor}#{data.patch}"}
  end

  defp find_or_create_account(%{username: username, password: password}=data) do
    case Account.find_by_username(username) |> Repo.one do
      nil ->
        with {:error, _} <- Map.from_struct(data) |> Account.new() |> Repo.insert,
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
