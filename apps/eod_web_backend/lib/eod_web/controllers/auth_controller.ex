defmodule EOD.Web.AuthController do
  @moduledoc """
  This controller is solely repsonsible for handling authentication requests
  of users to ensure they meet the access requirements found in the gameserver
  """

  use EOD.Web, :controller
  alias EOD.Web.AuthContext
  alias EOD.Web.Guardian

  def login(conn, params) do
    case AuthContext.find_and_verify_account_password(params) do
      {:error, _} ->
        send_resp(conn, 401, "")

      {:ok, account} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(account, %{})
        render(conn, "show.json", token: token)
    end
  end

  def logout(conn, _params) do
    send_resp(conn, 200, "")
  end

  def info(conn, _params) do
    with %{current_user: user} <- conn.assigns do
      render(conn, "info.json", user: user)
    else
      _ ->
        send_resp(conn, 401, "")
    end
  end
end
