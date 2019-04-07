defmodule EOD.Packet.Server.LoginDenied do
  @moduledoc """
  Following a login request, this packet is sent to the client letting it
  know that their request is denied and why.  There are a myriad of
  different reasons to send to the client.  Some of the rest of the packet
  appears somewhat unknown; however, it does require the server major and
  minor bytes to be sent as well.

  See:
    * `EOD.Packet.Client.LoginRequest`
  """
  use EOD.Packet do
    code(0x2C)

    enum :reason, :integer, size: [bytes: 1], default: 0x02 do
      0x01 -> :wrong_password
      0x02 -> :account_invalid
      0x03 -> :auth_server_unavailable
      0x05 -> :client_version_too_low
      0x06 -> :cannot_access_user_account
      0x07 -> :account_not_found
      0x08 -> :account_no_access_any_game
      0x09 -> :account_no_access_this_game
      0x0A -> :account_closed
      0x0B -> :account_already_logged_in
      0x0C -> :too_many_players_logged_in
      0x0D -> :game_currently_closed
      0x10 -> :logged_in_to_another_server
      0x11 -> :account_in_logout_procedure
      0x12 -> :invite_required
      0x13 -> :account_is_banned
      0x14 -> :cafe_is_out_of_playing_time
      0x15 -> :personal_account_is_out_of_time
      0x16 -> :cafe_account_is_suspended
      0x17 -> :expansion_version_not_permited
    end

    blank(using: 0x01, size: [bytes: 1])
    field(:major, :integer, size: [bytes: 1])
    field(:minor, :integer, size: [bytes: 1])
    blank(using: 0x00, size: [bytes: 2])
  end
end
