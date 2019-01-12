defmodule EOD.Socket.Listener do
  @moduledoc """
  This is a simple process wrapper that reads packets from a provided
  socket and sends them to another process.  By default the caller is
  where packets are sent; however, this can be overriden with the
  `receiver` opt.

  The packet is sent to the receiving process as `{:packet, packet}`,
  but this can be overriden with the `wrap` option, which defaults to
  `:packet`.  Therefore if you use a wrap of `{:foo, :bar}` then
  new packets messages will be in the format of `{{:foo, :bar}, packet}`
  """
  alias EOD.Socket

  defstruct socket: nil,
            receiver: nil,
            wrap: :packet

  def start_link(socket, opts \\ []) do
    receiver = Keyword.get(opts, :receiver, self())
    wrap = Keyword.get(opts, :wrap, :packet)

    spawn_link(fn ->
      listen(%__MODULE__{socket: socket, receiver: receiver, wrap: wrap})
    end)
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
