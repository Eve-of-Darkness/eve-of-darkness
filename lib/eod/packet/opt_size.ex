defmodule EOD.Packet.OptSize do
  @moduledoc """
  A simple parser for the size of fields that are defined by a packet
  """

  @doc """
  Given a field name for reporting on error, and the field options this
  attempts to convert sizes given to it to a granularity of bits as whole
  numbers can be defined in bits at the base level.
  """
  def number_size_opt(name, opts) do
    case Keyword.get(opts, :size, 1) do
      [bits: number] when is_integer(number) ->
        number

      [bytes: number] when is_integer(number) ->
        number * 8

      number when is_integer(number) ->
        number * 8

      wrong_opt ->
        raise ArgumentError, "Invalid size for field :#{name} [#{inspect(wrong_opt)}]"
    end
  end

  @doc """
  Given a field name for reporting on error and the field size, this attempts to
  return the number of bytes a string size is.
  """
  def string_size_opt(name, opts) do
    case Keyword.get(opts, :size, nil) do
      number when is_integer(number) ->
        number

      [bytes: number] when is_integer(number) ->
        number

      [bits: _] ->
        raise ArgumentError, "Invalid size for string :#{name}, must be in bytes"

      nil ->
        raise ArgumentError, "Invalid field #{name}, a size is required"
    end
  end
end
