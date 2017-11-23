defmodule EOD.Socket.TCP.Encoding.LoginRequest do
  @moduledoc false

  def decode(%{data: data}, id) do
    with <<_::bytes-size(7),
           usize::little-integer-size(16), uname::bytes-size(usize),
           psize::little-integer-size(16), pword::bytes-size(psize),
           _::binary>> <- data
    do
      {:ok,
        %{id: id, username: uname, password: pword}}
    else
      _ ->
        {:error, :bad_login_request}
    end
  end
end
