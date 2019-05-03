defmodule EOD.Web.Guardian do
  @moduledoc """
  This is responsible for knowing how to produce a token from an account
  and vise-versa, find an account from a token.

  For more information see: https://github.com/ueberauth/guardian#guardian
  """

  use Guardian, otp_app: :eod_web_backend

  alias EOD.Repo
  alias EOD.Repo.Account

  def subject_for_token(%Account{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_resource, _claims) do
    {:error, :invalid_resource}
  end

  def resource_from_claims(%{"sub" => sub}) do
    Repo.get(Account, sub)
    |> case do
      nil ->
        {:error, :no_resource}

      account ->
        {:ok, account}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end

  def auth_error(conn, {_type, _reason}, _opts) do
    import Plug.Conn
    send_resp(conn, 401, "")
  end
end
