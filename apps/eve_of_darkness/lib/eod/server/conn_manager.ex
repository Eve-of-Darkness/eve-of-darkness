defmodule EOD.Server.ConnManager do
  @moduledoc """
  A bridge between the network and the server, this handles
  incoming TCP connections by listening on a given port,
  accepting new connections and send freshly opened
  client connections to a provided callback process.

  By default client sockets are sent to the process that
  started the `ConnManager`; however, this can be changed
  via the `:callback` opt
  """
  use GenServer

  defstruct socket: nil,
            port: nil,
            callback: nil,
            accepting_pid: nil,
            wrap: :none

  @doc """
  Starts up a ConnManager on the for the given port.  It should
  be noted that it opens this port and begins listening on startup

  Options:
    * :port - the port number to listen on
    * :wrap - a three element tuple with format of {Module, :fun, [args]}, if
        provided each new socket will dynamically call this and append the
        socket as the first argument to the function
    * :callback - a three element tuple with format of {:send, any(), pid()}
        when a new connection is accepted it is sent as a two element
        tuple of {any(), client}
  """
  def start_link(opts \\ []) do
    with {:ok, port} <- opts |> Keyword.get(:port, 10_300) |> parse_port,
         {:ok, clbk} <- opts |> Keyword.get(:callback, def_clbk()) |> check_callback,
         {:ok, wrap} <- opts |> Keyword.get(:wrap, :none) |> check_wrap,
         {:ok, sock} <- :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true]) do
      GenServer.start_link(
        __MODULE__,
        %__MODULE__{port: port, socket: sock, callback: clbk, wrap: wrap}
      )
    end
  end

  @doc """
  Stops the ConnManager.  This should be used to gracefully close the listening
  port and sending mechanism of the manager.
  """
  def stop(pid) when is_pid(pid) do
    GenServer.stop(pid)
  end

  # GenServer Callbacks

  def init(state) do
    {:ok, state |> start_accepting}
  end

  def terminate(_, state) do
    Supervisor.stop(state.accepting_pid)
    :gen_tcp.close(state.socket)
  end

  # Private Functions

  defp parse_port(num) when is_integer(num) and num in 1..65_535, do: {:ok, num}

  defp parse_port(num) when is_binary(num) do
    case Integer.parse(num) do
      {port, ""} -> parse_port(port)
      :error -> {:error, :invalid_port}
    end
  end

  defp parse_port(_), do: {:error, :invalid_port}

  defp def_clbk, do: {:send, :new_conn, self()}

  defp check_callback({:send, _, pid} = clbk) when is_pid(pid), do: {:ok, clbk}

  defp check_wrap(:none), do: {:ok, :none}

  defp check_wrap({module, fun, args} = wrap)
       when is_atom(module) and is_atom(fun) and is_list(args),
       do: {:ok, wrap}

  defp check_wrap(_), do: {:error, :invalid_wrap}

  defp start_accepting(state) do
    {:ok, supervisor} = Task.Supervisor.start_link(restart: :permanent)
    Task.Supervisor.start_child(supervisor, fn -> accept(state) end)
    %{state | accepting_pid: supervisor}
  end

  defp accept(state) do
    {:ok, client_socket} = :gen_tcp.accept(state.socket)

    wrapped_socket =
      case state.wrap do
        :none -> client_socket
        {module, fun, args} -> apply(module, fun, [client_socket | args])
      end

    case state.callback do
      {:send, term, pid} -> send(pid, {term, wrapped_socket})
    end

    accept(state)
  end
end
