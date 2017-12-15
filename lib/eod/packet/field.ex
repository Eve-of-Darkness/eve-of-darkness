defmodule EOD.Packet.Field do
  @callback struct_field_pair({any(), Keyword.t}) :: {atom(), any()} | nil

  @callback from_binary_match({any(), Keyword.t}) :: Macro.t | nil
  @callback from_binary_struct({any(), Keyword.t}) :: Macro.t | nil
  @callback from_binary_process({any(), Keyword.t}) :: Macro.t | nil

  @callback to_binary_match({any(), Keyword.t}) :: Macro.t | nil
  @callback to_binary_bin({any(), Keyword.t}) :: Macro.t | nil
  @callback to_binary_process({any(), Keyword.t}) :: Macro.t | nil

  @callback size({any(), Keyword.t}) :: integer() | :dynamic | :anchored_dynamic

  defmacro __using__(_) do
    quote do
      @behaviour EOD.Packet.Field
      def from_binary_process(_), do: nil
      def to_binary_process(_), do: nil
      defoverridable [from_binary_process: 1]
      defoverridable [to_binary_process: 1]
    end
  end
end
