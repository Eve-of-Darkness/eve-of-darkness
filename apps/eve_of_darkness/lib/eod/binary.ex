defmodule EOD.Binary do
  @moduledoc """
  This is a setup of helper functions that make looking at and reasoning with
  binary data a little easier.  The initial inspiration of this was attempting
  to compare real data versus data created by the server at the binary level.
  """

  def readable_data_binary(data, leftpad \\ "") do
    for(<<byte::8 <- data>>, do: byte)
    |> Enum.chunk_every(12, 12, Stream.repeatedly(fn -> nil end))
    |> Enum.map(fn byte_list ->
      "#{leftpad}#{Enum.map(byte_list, &hex/1) |> Enum.join(" ")}  #{
        Enum.map(byte_list, &ascii/1)
      }"
    end)
    |> Enum.join("\n")
  end

  defp hex(num) when is_integer(num), do: Base.encode16(<<num::8>>)
  defp hex(byte) when byte_size(byte) == 1, do: Base.encode16(byte)
  defp hex(nil), do: "  "

  defp ascii(nil), do: ""
  defp ascii(num) when num in 32..126, do: <<num::8>>
  defp ascii(_), do: "."
end
