defmodule EOD.Server.ConnManagerTest do
  use ExUnit.Case, async: true
  alias EOD.Server.ConnManager, as: CM

  defmodule Wrap do
    defstruct socket: nil
    def new(sock) when is_port(sock), do: %__MODULE__{socket: sock}
  end

  test "starts up fine..." do
    assert {:ok, pid} = CM.start_link()
    assert is_pid(pid)
    assert Process.alive?(pid)
    CM.stop(pid)
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
    {:ok, pid} = CM.start_link(port: 22123)
    {:ok, port} = :gen_tcp.connect('localhost', 22123, [:binary, active: false])
    :gen_tcp.close(port)
    assert_receive {:new_conn, sock}
    assert is_port(sock)
    CM.stop(pid)
  end

  test "can define a custom callback send pattern" do
    ref = make_ref()
    {:ok, pid} = CM.start_link(port: 22124, callback: {:send, {:conn!, ref}, self()})
    {:ok, port} = :gen_tcp.connect('localhost', 22124, [:binary, active: false])
    :gen_tcp.close(port)
    assert_receive {{:conn!, ^ref}, sock}
    assert is_port(sock)
    CM.stop(pid)
  end

  test "can wrap a socket before sending" do
    {:ok, pid} = CM.start_link(port: 22125, wrap: {Wrap, :new, []})
    {:ok, port} = :gen_tcp.connect('localhost', 22125, [:binary, active: false])
    :gen_tcp.close(port)
    assert_receive {:new_conn, %Wrap{socket: sock}}
    assert is_port(sock)
    CM.stop(pid)
  end
end
