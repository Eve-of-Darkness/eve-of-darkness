defmodule EOD.Server.ConnManagerTest do
  use ExUnit.Case, async: true
  alias EOD.Server.ConnManager, as: CM

  defmodule Wrap do
    defstruct socket: nil
    def new(sock) when is_port(sock), do: %__MODULE__{socket: sock}
  end

  defmodule Callback do
    def clbk(socket, pid_as_param) do
      :gen_tcp.controlling_process(socket, pid_as_param)
      send(pid_as_param, {:made_it_back, socket})
    end
  end

  test "starts up fine..." do
    assert {:ok, pid} = CM.start_link()
    assert is_pid(pid)
    assert Process.alive?(pid)
    assert :ok = CM.stop(pid)
    refute Process.alive?(pid)
  end

  test "fails on a bad port" do
    assert {:error, :invalid_port} = CM.start_link(port: "roflcopter")
  end

  test "fails when port already taken" do
    {:ok, port} = :gen_tcp.listen(13_370, [:binary, active: false])
    return = CM.start_link(port: 13_370)
    :gen_tcp.close(port)
    assert {:error, :eaddrinuse} == return
  end

  test "sends new socket connections to host pid by default" do
    {:ok, pid} = CM.start_link(port: 22_123)
    {:ok, port} = :gen_tcp.connect('localhost', 22_123, [:binary, active: false])
    :gen_tcp.close(port)
    assert_receive {:new_conn, sock}
    assert is_port(sock)
    assert :ok = :gen_tcp.controlling_process(sock, self())
    CM.stop(pid)
  end

  test "can define a custom callback send pattern" do
    ref = make_ref()
    {:ok, pid} = CM.start_link(port: 22_124, callback: {:send, {:conn!, ref}, self()})
    {:ok, port} = :gen_tcp.connect('localhost', 22_124, [:binary, active: false])
    :gen_tcp.close(port)
    assert_receive {{:conn!, ^ref}, sock}
    assert is_port(sock)
    CM.stop(pid)
  end

  test "can wrap a socket before sending" do
    {:ok, pid} = CM.start_link(port: 22_125, wrap: {Wrap, :new, []})
    {:ok, port} = :gen_tcp.connect('localhost', 22_125, [:binary, active: false])
    :gen_tcp.close(port)
    assert_receive {:new_conn, %Wrap{socket: sock}}
    assert is_port(sock)
    CM.stop(pid)
  end

  test "can be given a mfa callback where socket is appened to args" do
    {:ok, pid} = CM.start_link(port: 22_126, callback: {:call, {Callback, :clbk, [self()]}})
    {:ok, port} = :gen_tcp.connect('localhost', 22_126, [:binary, active: false])
    :gen_tcp.close(port)
    assert_receive {:made_it_back, sock}
    assert is_port(sock)
    assert :ok = :gen_tcp.controlling_process(sock, self())
    CM.stop(pid)
  end
end
