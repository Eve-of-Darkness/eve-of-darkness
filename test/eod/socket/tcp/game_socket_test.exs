defmodule EOD.Socket.TCP.GameSocketTest do
  use ExUnit.Case
  alias EOD.Socket.TCP.GameSocket
  alias EOD.Packet.Client.HandShakeRequest
  alias EOD.Socket.TCP.ClientPacket
  alias EOD.Socket.TCP.ServerPacket

  setup _ do
    {:ok, listen_port} = :gen_tcp.listen(31_000, [:binary, active: false, reuseaddr: true])

    controlling_pid = self()

    listen_task =
      Task.async(fn ->
        {:ok, port} = :gen_tcp.accept(listen_port)
        :gen_tcp.controlling_process(port, controlling_pid)
        {:ok, port}
      end)

    {:ok, client_sock} = :gen_tcp.connect('localhost', 31_000, [:binary, active: false])
    {:ok, server_sock} = Task.await(listen_task)

    {:ok, server: server_sock, client: client_sock}
  end

  describe "handling packets without inspection" do
    setup %{server: server} do
      gamesocket = GameSocket.new(server)
      refute gamesocket.inspector
      {:ok, gamesocket: gamesocket}
    end

    @tag capture_log: true
    test "sending data as a normal map is an unknown error", %{gamesocket: socket} do
      assert {:error, :unknown_tcp_message} = GameSocket.send(socket, %{roflcopter: "garbage"})
    end

    test "sending a known server packet", %{gamesocket: socket, client: client} do
      alias EOD.Packet.Server.AssignSession
      assert :ok = GameSocket.send(socket, %AssignSession{session_id: 12})
      assert {:ok, <<0, 2, 40, 12, 0>>} == :gen_tcp.recv(client, 0)
    end

    test "receiving a known client packet", %{gamesocket: socket, client: client} do
      :gen_tcp.send(
        client,
        <<0, 7, 0, 1, 0, 0, 0, 0, 0, 244, 54, 1, 1, 24, 98, 105, 5, 138, 220>>
      )

      assert {:ok, packet} = GameSocket.recv(socket)
      assert %ClientPacket{} = packet
      assert %HandShakeRequest{} = packet.data
    end

    test "receiving a segmented packet", %{gamesocket: socket, client: client} do
      Task.async(fn ->
        :gen_tcp.send(client, <<0, 7, 0, 1, 0, 0, 0, 0, 0, 244>>)
        :gen_tcp.send(client, <<54, 1, 1, 24, 98, 105, 5, 138, 220>>)
      end)

      assert {:ok, packet} = GameSocket.recv(socket)
      assert %ClientPacket{} = packet
      assert %HandShakeRequest{} = packet.data
    end
  end

  describe "handling packets with inspection" do
    alias EOD.Socket.Inspector
    alias EOD.TestSubscription, as: Subscription

    setup %{server: server} do
      {:ok, inspector} = Inspector.start_link()
      {:ok, subscription} = Subscription.start_link()
      inspector |> Inspector.subscribe(subscription)
      Subscription.wait_for_subscribtion(subscription, inspector)

      {:ok, gamesocket} =
        server
        |> GameSocket.new()
        |> GameSocket.add_inspector(inspector)

      {:ok, gamesocket: gamesocket, sub: subscription, inspector: inspector}
    end

    test "sending a known server packet", %{gamesocket: socket, client: client, sub: sub} do
      alias EOD.Packet.Server.AssignSession
      alias EOD.Socket.TCP.ServerPacket

      assert :ok = GameSocket.send(socket, %AssignSession{session_id: 12})
      assert {:ok, <<0, 2, 40, 12, 0>>} == :gen_tcp.recv(client, 0)
      [log] = Subscription.get_logs(sub)
      assert log.action == :send
      assert log.id
      assert %{data: data, raw: raw} = log.data
      assert <<0, 2, 40, 12, 0>> == IO.iodata_to_binary(raw)
      assert %ServerPacket{code: 0x28, data: [<<12, 0>>]} = data
    end

    test "receiving a known client packet", %{gamesocket: socket, client: client, sub: sub} do
      :gen_tcp.send(
        client,
        <<0, 7, 0, 1, 0, 0, 0, 0, 0, 244, 54, 1, 1, 24, 98, 105, 5, 138, 220>>
      )

      assert {:ok, packet} = GameSocket.recv(socket)
      assert %ClientPacket{} = packet
      assert %HandShakeRequest{} = packet.data
      [log] = Subscription.get_logs(sub)
      assert log.action == :recv
      assert log.id

      %{raw: raw, data: data} = log.data
      assert raw == <<0, 7, 0, 1, 0, 0, 0, 0, 0, 244, 54, 1, 1, 24, 98, 105, 5, 138, 220>>
      assert %ClientPacket{id: :handshake_request, size: 7} = data

      assert %HandShakeRequest{
               addons: 3,
               build: 26885,
               major: 1,
               minor: 1,
               patch: 24,
               rev: 98,
               type: 6
             } = data.data
    end

    test "receiving a segmented packet", %{gamesocket: socket, client: client, sub: sub} do
      Task.async(fn ->
        :gen_tcp.send(client, <<0, 7, 0, 1, 0, 0, 0, 0, 0, 244>>)
        :gen_tcp.send(client, <<54, 1, 1, 24, 98, 105, 5, 138, 220>>)
      end)

      assert {:ok, packet} = GameSocket.recv(socket)
      assert %ClientPacket{} = packet
      assert %HandShakeRequest{} = packet.data

      [log] = Subscription.get_logs(sub)
      assert log.action == :recv
      assert log.id

      %{raw: raw, data: data} = log.data
      assert raw == <<0, 7, 0, 1, 0, 0, 0, 0, 0, 244, 54, 1, 1, 24, 98, 105, 5, 138, 220>>
      assert %ClientPacket{id: :handshake_request, size: 7} = data

      assert %HandShakeRequest{
               addons: 3,
               build: 26885,
               major: 1,
               minor: 1,
               patch: 24,
               rev: 98,
               type: 6
             } = data.data
    end
  end
end
