defmodule EOD.Socket.Listener do
  alias EOD.Socket

  defstruct socket: nil,
            receiver: nil,
            wrap: :packet

  def start_link(socket, opts \\ []) do
    receiver = Keyword.get(opts, :receiver, self())
    wrap = Keyword.get(opts, :wrap, :packet)
    spawn_link fn ->
      listen(%__MODULE__{socket: socket, receiver: receiver, wrap: wrap})
    end
  end

  defp listen(state) do
    case Socket.recv(state.socket) do
      {:ok, packet} ->
        send(state.receiver, {state.wrap, packet})
        listen(state)

      {:error, reason} when reason in [:enotconn, :closed, :ealready] ->
        send(state.receiver, {state.wrap, :error, reason})

      {:error, reason} ->
        send(state.receiver, {state.wrap, :error, reason})
        listen(state)
    end
  end
end
