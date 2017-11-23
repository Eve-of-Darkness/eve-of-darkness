defprotocol EOD.Socket do
  @moduledoc """
  An abstraction around a data socket.  The purpose of this is
  to insulate the project from raw sockets opened by the system
  and provide support for automatic encoding / decoding of packets

  Another goal of this module is to make it easier to mock network
  communication that you would have with the client for tests.
  """

  def recv(socket)
  def send(socket, data)
  def close(socket)
end
