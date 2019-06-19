defmodule EOD.Packet.Field.PascalStringTest do
  use ExUnit.Case, async: true

  describe "Null Terminated Pascale Strings" do
    defmodule NullTerminated do
      use EOD.Packet do
        field(:name, :pascal_string, size: 4, type: :little, null_terminated: true)
      end
    end

    test "works as a struct" do
      assert %NullTerminated{name: "John"}
    end

    test "creates the correct binary" do
      assert {:ok, <<5, 0, 0, 0, "John"::binary, 0>>} =
               %NullTerminated{name: "John"} |> NullTerminated.to_binary()
    end

    test "creates correct string from binary" do
      assert {:ok, %NullTerminated{name: "John"}} =
               <<5, 0, 0, 0, "John"::binary, 0>> |> NullTerminated.from_binary()
    end
  end
end
