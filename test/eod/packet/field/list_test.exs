defmodule EOD.Packet.Field.ListTest do
  use ExUnit.Case, async: true

  defmodule Fixed do
    use EOD.Packet do
      structure Widget do
        field :name, :pascal_string
      end

      list :widgets, Widget, size: 3
    end
  end

  defmodule Dynamic do
    use EOD.Packet do
      structure Widget do
        field :name, :pascal_string
      end

      list :widgets, Widget, size: :dynamic
    end
  end

  describe "Fixed list size" do
    test "should have exactly three by default" do
      fixed = %Fixed{}
      assert fixed.widgets |> Enum.count == 3
      assert fixed.widgets |> Enum.all?(&match?(%Fixed.Widget{}, &1))
    end

    test "it can create a binary" do
      alias Fixed.Widget

      {:ok, bin} =
        %Fixed{widgets: ~w(foo bar baz) |> Enum.map(& %Widget{name: &1})}
        |> Fixed.to_binary

      assert <<3, "foo", 3, "bar", 3, "baz">> == bin
    end

    test "it can be created from a binary" do
      {:ok, fixed} =
        <<3, "foo", 3, "bar", 3, "baz">>
        |> Fixed.from_binary

      assert ~w(foo bar baz) == fixed.widgets |> Enum.map(& &1.name)
    end
  end

  describe "Size being dynamic" do
    test "should be an empty list by default" do
      dynamic = %Dynamic{}
      assert dynamic.widgets == []
    end

    test "it can create a binary" do
      {:ok, bin} =
        %Dynamic{widgets: ~w(foo bar) |> Enum.map(& %Dynamic.Widget{name: &1})}
        |> Dynamic.to_binary

      assert bin == <<3, "foo", 3, "bar">>
    end

    test "in can be created from a binary" do
      {:ok, dynamic} =
        <<3, "foo", 3, "bar", 3, "baz", 4, "buzz">>
        |> Dynamic.from_binary

      assert dynamic.widgets |> Enum.map(& &1.name) == ~w(foo bar baz buzz)
    end

    test "an empty list works as well when converting" do
      {:ok, bin} = %Dynamic{} |> Dynamic.to_binary
      {:ok, dynamic} = bin |> Dynamic.from_binary
      assert dynamic.widgets == []
    end
  end
end
