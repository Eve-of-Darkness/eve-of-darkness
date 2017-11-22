defmodule EOD.SocketTest do
  use ExUnit.Case, async: true
  alias EOD.Socket

  @conn_opts [:binary, active: false, reuseaddr: true]

  defmodule TestSource do
    def new, do: Agent.start_link(fn -> [] end)
    def send(agent, data),
      do: Agent.update(agent, fn stack -> [data|stack] end)
    def recv(agent),
      do: {:ok, Agent.get_and_update(agent, fn [item | rem] -> {item, rem} end)}
    def close(agent), do: Agent.stop(agent)
  end

  defmodule SimpleSocket do
    def send(_, data) do
      Kernel.send(self(), data)
      :ok
    end
    def recv(_), do: {:ok, "Echo"}
    def close(_), do: :ok
  end

  defmodule TestCoder do
    def decode(msg), do: {:ok, String.upcase(msg)}
    def encode(msg), do: {:ok, String.downcase(msg)}
  end

  describe ":gen_tcp socket functionality" do
    setup _ do
      {:ok, tcp_sock} = :gen_tcp.listen(44_445, @conn_opts)
      {:ok, tcp_client} = :gen_tcp.connect('localhost', 44_445, @conn_opts)
      {:ok, tcp_server} = :gen_tcp.accept(tcp_sock)

      on_exit(fn ->
        :gen_tcp.close(tcp_sock)
        :gen_tcp.close(tcp_client)
        :gen_tcp.close(tcp_server)
      end)

      {:ok, tcp_sock: tcp_sock,
            client: Socket.new(tcp_client),
            server: Socket.new(tcp_server)}
    end

    test "you can send and receive data", context do
      assert :ok = Socket.send(context.server, "test")
      assert {:ok, "test"} = Socket.recv(context.client)
    end

    test "you can close a socket", context do
      assert :ok = Socket.close(context.client)
      assert {:error, :closed} = Socket.send(context.client, "test")
      assert {:error, :closed} = Socket.recv(context.server)
    end
  end

  describe "a custom socket source" do
    setup _ do
      {:ok, agent} = TestSource.new
      {:ok, custom_socket: Socket.new(agent, source: TestSource),
            agent: agent}
    end

    test "you can add to it", context do
      assert :ok = Socket.send(context.custom_socket, "test")
      assert "test" = Agent.get(context.agent, &hd(&1))
    end

    test "you can get from it", context do
      :ok = Agent.update(context.agent, fn _ -> ["test"] end)
      assert {:ok, "test"} = Socket.recv(context.custom_socket)
    end

    test "you can close it", context do
      assert :ok = Socket.close(context.custom_socket)
      refute Process.alive?(context.agent)
    end
  end

  describe "using encoders and decoders" do
    setup _ do
      {:ok, simple_socket: Socket.new(nil, source: SimpleSocket,
                                           encoder: TestCoder,
                                           decoder: TestCoder)}
    end


    test "it encodes as you would expect", context do
      assert :ok = Socket.send(context.simple_socket, "TEST")
      assert_receive "test"
    end

    test "it decodes as you would expect", context do
      assert {:ok, "ECHO"} = Socket.recv(context.simple_socket)
    end
  end
end
