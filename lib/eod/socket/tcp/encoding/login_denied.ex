defmodule EOD.Socket.TCP.Encoding.LoginDenied do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  @denial_reasons %{
    wrong_password: 0x01,
    account_invalid: 0x02,
    auth_server_unavailable: 0x03,
    client_version_too_low: 0x05,
    cannot_access_user_account: 0x06,
    account_not_found: 0x07,
    account_no_access_any_game: 0x08,
    account_no_access_this_game: 0x09,
    account_closed: 0x0a,
    account_already_logged_in: 0x0b,
    too_many_players_logged_in: 0x0c,
    game_currently_closed: 0x0d,
    logged_in_to_another_server: 0x10,
    account_in_logout_procedure: 0x11,
    invite_required: 0x12,
    account_is_banned: 0x13,
    cafe_is_out_of_playing_time: 0x14,
    personal_account_is_out_of_time: 0x15,
    cafe_account_is_suspended: 0x16,
    expansion_version_not_permited: 0x17,
    service_not_available: 0xa
  }

  @default_reason  @denial_reasons.service_not_available

  def encode(
    code,
    data = %{major: major, minor: minor}
  ) do
    {:ok,
      new(code)
      |> write_byte(reason(data))
      |> write_byte(0x01)
      |> write_byte(major)
      |> write_byte(minor)
      |> write_byte(0x00)
      |> write_byte(0x00)}
  end
  def encode(_, _), do: {:error, :login_granted_encode}

  def reason(%{reason: reason}), do: @denial_reasons[reason] || @default_reason
  def reason(_), do: @default_reason
end

