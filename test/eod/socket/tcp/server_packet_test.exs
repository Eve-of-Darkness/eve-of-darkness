defmodule EOD.Socket.TCP.ServerPacketTest do
  use ExUnit.Case, async: true
  import EOD.Socket.TCP.ServerPacket

  defp data_flattened(%{data: data}) do
    List.flatten(data)
  end

  setup tags do
    {:ok, p: new(tags[:code] || 0x00) }
  end

  describe "write_byte/2" do
    test "writing integers", %{p: pak} do
      assert [12] == pak |> write_byte(12) |> data_flattened
      assert [12, 0] == pak |> write_byte(12) |> write_byte(0) |> data_flattened
    end

    test "writing bytes", %{p: pak} do
      assert [255] == pak |> write_byte(<<255::8>>) |> data_flattened
      assert [191, 38] ==
        pak |> write_byte(<<191::8>>) |> write_byte(<<38::8>>) |> data_flattened
    end
  end

  describe "write_string/2" do
    test "a single string", %{p: pak} do
      assert ["test"] == pak |> write_string("test") |> data_flattened
    end

    test "several strings", %{p: pak} do
      assert ~w(one two) ==
        pak |> write_string("one") |> write_string("two") |> data_flattened
    end
  end

  describe "write_string/3" do
    test "writing under the size", %{p: pak} do
      assert ["test"] = pak |> write_string("test", 30) |> data_flattened
    end

    test "writing over the size", %{p: pak} do
      assert ["te"] = pak |> write_string("test", 2) |> data_flattened
    end

    test "writing several strings", %{p: pak} do
      assert ~w(te st) ==
        pak |> write_string("test", 2) |> write_string("start", 2) |> data_flattened
    end
  end

  describe "to_iolist/1" do
    setup %{p: pak} do
      {:ok, p: put_in(pak.data, [5, 5, 10])}
    end

    test "the size of data is a head with two bytes", %{p: pak} do
      assert {:ok, [<<3::16>> | _]} = pak |> to_iolist
    end

    @tag code: 0xF4
    test "the code is second segment", %{p: pak} do
      assert {:ok, [_, 0xF4, _]} = pak |> to_iolist
    end

    test "the data payload is the third segment", %{p: pak} do
      assert {:ok, [_, _, [5, 5, 10]]} = pak |> to_iolist
    end
  end

  describe "write_16/2" do
    test "an integer is packed as two bytes", %{p: pak} do
      assert [<<41::16>>] == pak |> write_16(41) |> data_flattened
      assert [<<160, 40>>, <<41::16>>] ==
        pak |> write_16(41_000) |> write_16(41) |> data_flattened
    end

    test "two bytes are added", %{p: pak} do
      assert [<<41, 0x01>>] = pak |> write_16(<<41, 1>>) |> data_flattened
    end
  end

  describe "write_32/2" do
    test "a integer is packed as 4 bytes", %{p: pak} do
      assert [<<41::32>>] == pak |> write_32(41) |> data_flattened
    end

    test "four bytes are appended", %{p: pak} do
      assert [<<0, 0, 0, 0>>, <<1, 1, 1, 1>>] =
        pak |> write_32(0) |> write_32(<<1, 1, 1, 1>>) |> data_flattened
    end
  end

  describe "write_pascal_string/2" do
    test "the size is the first part", %{p: pak} do
      assert [4,_] = pak |> write_pascal_string("test") |> data_flattened
    end

    test "the string is the next segment", %{p: pak} do
      assert [_, "test"] = pak |> write_pascal_string("test") |> data_flattened
    end
  end

  describe "fill_bytes/3" do
    test "0 is a no-op", %{p: pak} do
      assert [] == pak |> fill_bytes(0xf1, 0) |> data_flattened
    end

    test "writing just 1", %{p: pak} do
      assert [0xf1] == pak |> fill_bytes(0xf1, 1) |> data_flattened
    end

    test "writing several", %{p: pak} do
      assert [5, 5, 5, 5] == pak |> fill_bytes(0x05, 4) |> data_flattened
    end
  end

  describe "write_little_16/2" do
    test "with an integer", %{p: pak} do
      assert [<<19, 0>>] == pak |> write_little_16(19) |> data_flattened
    end

    test "with two bytes", %{p: pak} do
      assert [<<5, 9>>] == pak |> write_little_16(<<9, 5>>) |> data_flattened
    end
  end

  describe "write_fill_string/3" do
    test "past the max length", %{p: pak} do
      assert ["te"] == pak |> write_fill_string("test", 2) |> data_flattened
    end

    test "when same length", %{p: pak} do
      assert ["test"] == pak |> write_fill_string("test", 4) |> data_flattened
    end

    test "under length", %{p: pak} do
      assert ["test", 0, 0] ==
        pak |> write_fill_string("test", 6) |> data_flattened
    end
  end
end
