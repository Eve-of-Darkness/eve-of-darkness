defmodule EOD.Socket.TCP.Encoding.PingRequest do
  @moduledoc false

  def decode(%{data: data, sequence: seq}, id) do
    with <<_::32, timestamp::32, _::32>> <- data do
      {:ok, %{id: id, sequence: seq, timestamp: timestamp}}
    else
      _ ->
        {:error, :bad_ping_request}
    end
  end
end
