defmodule EOD.Socket.TCP.Encoding.Realm do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket
  @realms ~w(none albion midgard hibernia all)a

  def encode(code, %{realm: realm}) when realm in @realms do
    realm = case realm do
      :albion -> 1
      :midgard -> 2
      :hibernia -> 3
      _ -> 0
    end

    {:ok, new(code) |> write_byte(realm)}
  end
  def encode(_, _), do: {:error, :send_realm_encode}
end
