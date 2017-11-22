defmodule EOD.Socket do
  @moduledoc """
  An abstraction around a data socket.  The purpose of this is
  to insulate the project from raw sockets opened by the system
  and provide support for automatic encoding / decoding of packets

  Another goal of this module is to make it easier to mock network
  communication that you would have with the client for tests.

  The core concept of this module revolves around a `source` module
  which knows how to perform three primary actions against what it
  considers a `socket`.  See `TcpSource` for an example of a source.

  You can also provide an encoder and decoder module for a socket.
  Each must have and `encode/1` and `decode/1` respectively and return
  {:ok, result} on success.
  """

  defmodule RawEncoding do
    @moduledoc "Default raw encoding for `EOD.Socket`"
    def encode(data), do: {:ok, data}
    def decode(data), do: {:ok, data}
  end

  defmodule TcpSource do
    @moduledoc "Default TCP Socket Source"
    def send(socket, data), do: :gen_tcp.send(socket, data)
    def recv(socket), do: :gen_tcp.recv(socket, 0)
    def close(socket), do: :gen_tcp.close(socket)
  end

  defstruct socket: nil,
            source: TcpSource,
            decoder: RawEncoding,
            encoder: RawEncoding

  def new(socket_like, opts \\ []) do
    %__MODULE__{
      socket: socket_like,
      source: opts[:source] || TcpSource,
      decoder: opts[:decoder] || RawEncoding,
      encoder: opts[:encoder] || RawEncoding
    }
  end

  def recv(%__MODULE__{socket: socket, decoder: decoder, source: source}) do
    case source.recv(socket) do
      {:ok, data} -> data |> decoder.decode()
      any -> any
    end
  end

  def send(%__MODULE__{socket: socket, encoder: encoder, source: source}, packet) do
    case encoder.encode(packet) do
      {:ok, data} -> source.send(socket, data)
      any -> any
    end
  end

  def close(%__MODULE__{socket: socket, source: source}) do
    source.close(socket)
  end
end
