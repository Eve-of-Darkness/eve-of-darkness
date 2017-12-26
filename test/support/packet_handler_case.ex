defmodule EOD.PacketHandlerCase do
  @moduledoc """
  This is a helper module to make packet handler testing easier.  One of things
  required for a lot of these tests is to send `:handler` in a setup to identify
  what packet handler is being observed.
  """
  use ExUnit.CaseTemplate
  alias EOD.{Client, TestSocket, Socket, Server}
  alias EOD.Socket.TCP.ClientPacket
  import EOD.Repo.Factory

  using do
    quote do
      import Ecto.Query, only: [from: 2]
      import EOD.Repo.Factory
      import EOD.PacketHandlerCase
      alias EOD.{Repo, Socket, Packet, Client, Server}
    end
  end

  setup tags do
    setup_database_test_transactions(tags)
    server_settings = tags[:server_settings] || Server.Settings.new

    {:ok, socket} = TestSocket.start_link
    {:ok, server} = Server.start_link(conn_manager: :disabled, settings: server_settings)

    account = insert(:account)

    {:ok,
      client: %Client{session_id: tags[:session_id] || 7,
                      tcp_socket: socket,
                      server: server,
                      account: account},

      account: account,
      server: server,
      socket: TestSocket.set_role(socket, :client)}
  end

  @doc """
  This deligates the test context and the supplied packet to the packet handler's
  handle_packet/2 fucntion.  The packet can be either the fully qualified
  `ClientPacket` that is passed to the packet handler, or, it can be just the data
  struct portion.  If it is just the test struct portion it will assemble a
  `%ClientPacket` from it.

  As an extra check, this funtion will raise an exception if the handler's
  handle_packet/2 does not return `%Client{}`, as this is the expected flow for
  all packet handlers.
  """
  def handle_packet(%{client: client, handler: handler}, packet=%ClientPacket{}) do
    case apply(handler, :handle_packet, [client, packet]) do
      client = %Client{} -> client

      any ->
        raise """
        #{handler}.handle_packet/2 is expected to return a %EOD.Client{},
        Got #{inspect any} instead.
        """
    end
  end
  def handle_packet(client_and_handler, packet=%{__struct__: module}) do
    id = apply(module, :packet_id, [])
    handle_packet(client_and_handler, %ClientPacket{id: id, data: packet})
  end

  @doc """
  Grabs the next packet from the context that the packet handler has sent out
  """
  def received_packet(%{socket: socket}) do
    {:ok, packet} = Socket.recv(socket)
    packet
  end

  def update_client(context, key_vals) do
    Enum.reduce(key_vals, context, fn {key, val}, context ->
      put_in(context.client, Map.put(context.client, key, val))
    end)
  end

  @doc """
  Tests the context socket shared with the client's packet handler to see if
  the socket has been disconnected
  """
  def disconnected?(%{socket: socket}) do
    TestSocket.disconnected?(socket)
  end

  defp setup_database_test_transactions(tags) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(EOD.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(EOD.Repo, {:shared, self()})
    end
  end
end
