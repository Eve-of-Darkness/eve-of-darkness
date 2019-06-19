defmodule EOD.Packet do
  @moduledoc """
  This is a tool used to define the data for all packets that are transmitted
  by both the client and the server.  The general shape of the outer part of
  these packets are different, so this focuses on the data segment of packets.

  One of the biggest reasons for creating this was I didn't like how messy the
  encoding of packets was getting.  This aims to reduce the complexity of
  reading the game packets as well as be easy to change.
  """

  defmacro __using__(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :bin_patterns, accumulate: true)
      @substructure false

      # Fun little hack to import helper macros just for the scope
      # of the block provided with the `use` clause.  Took this idea
      # from the `Ecto.Schema` code.
      try do
        import EOD.Packet
        unquote(block)
      after
        :ok
      end

      Module.eval_quoted(__ENV__, [
        EOD.Packet.__defstruct__(@bin_patterns),
        EOD.Packet.__def_from_binary__(@bin_patterns |> Enum.reverse()),
        EOD.Packet.__def_to_binary__(@bin_patterns |> Enum.reverse()),
        EOD.Packet.__def_packet_size__(@bin_patterns |> Enum.reverse())
      ])
    end
  end

  @doc """
  Every packet has an identification code that is normally represented in
  hex format; however, it can be anything that is a valid binary sequence.
  The goal of this is to aid a routing system to determine what packet to
  use for decoding when fresh binary bytes arrive for processing.
  """
  defmacro code(code) do
    quote do
      def code, do: unquote(code)
    end
  end

  defmacro id(id) do
    quote do
      def packet_id, do: unquote(id)
    end
  end

  @doc """
  Creates a field that maps from a binary to the struct.  The magic behind
  this is the various different `types` that are supported. Each field
  instructs the module how to reach a series of bytes or bits from a binary
  and map them to a structure.  For this reason; the **order of the fields
  defined is important**.

  ### Example

  ```elixir
  defmodule Person do
    use EOD.Packet do
      field :first_name, :c_string, size: [bytes: 10]
      field :last_name, :c_string, size: [bytes: 10]
      field :age, :integer, size: [bytes: 1]
    end
  end
  ```

  This defines a structure for `Person` like so:
  ```elixir
  %Person{first_name: "", last_name: "", age: 0}
  ```

  The module can now be converted to binary and back again:

  ```elixir
  %Person{first_name: "ben", last_name: "falk", age: 35}
  |> Person.to_binary
  #=> <<"ben", 0::56, "falk", 0::48, 35::8>>
  ```

  ```elixir
  <<"mark", 0::48, "mill", 0::48, 22:8>>
  |> Person.from_binary
  #=> %Person{first_name: "mark", last_name: "mill", age: 22}
  ```
  """
  defmacro field(name, type, opts \\ []) do
    type = convert_known_types(type)

    quote bind_quoted: [name: name, type: type, opts: opts] do
      Module.put_attribute(__MODULE__, :bin_patterns, {name, type, opts})
    end
  end

  @doc """
  Used when there are parts of a binary stream that aren't needed and
  can essentially be skipped or unmapped.  You can specify what to blank
  this area out with for writing.

  ```elixir
  # blank our four bytes with 0's
  blank using: 0x00, size: [bytes: 4]
  ```

  There may also be a time for matching when you expect this blank unused
  field to be exactly a specific value; this is useful for instance as a header
  match for an assorted list.  Where you want to skip out if a known sequence
  for one of multiple substructures is possible. In the following example if the
  first encountered byte is exactly zero for each match it will match to
  `%Nothing{}`, without the `match_exactly?` option it would always match the
  first three bytes and never attempt to fill a `%Widget{}`

  ```elixir
  defmodule FixedAssorted do
    use EOD.Packet do
      structure Widget, do: field(:name, :pascal_string)
      structure Nothing, do: blank(using: 0x00, size: [bytes: 1], match_exactly?: true)

      list(:widgets, [Nothing, Widget], size: 3)
    end
  end
  ```
  """
  defmacro blank(opts) do
    quote do
      Module.put_attribute(
        __MODULE__,
        :bin_patterns,
        {nil, EOD.Packet.Field.Blank, unquote(opts)}
      )
    end
  end

  defmacro substructure(is_sub \\ true) when is_boolean(is_sub) do
    quote do
      @substructure unquote(is_sub)
    end
  end

  @doc """
  Sometimes you may have data that represents more then one idea from
  a field found in packet.  This allows you to declare this field and
  internally decode and encode it further without needing to use another
  module to perform this data abstraction.  The name you will not show
  up in the struct, but rather be used as an identifier for you to hand
  in your packet.  As an example, this defines a packet where a single
  c_string holds the user's first and last name:

  ```elixir
  defmodule Person do
    use EOD.Packet do
      compound :first_and_last, :c_string, size: [bytes: 100] do
        field :first_name, default: ""
        field :last_name, default: ""
      end
      field :age, :integer, size: [bytes: 1]
    end

    defp compound(:from_binary, :first_and_last, string) do
      [last_name,first_name] =
        String.split(string, ",")
        |> Enum.map(&String.trim/1)

      %{first_name: first_name, last_name: last_name}
    end

    defp compound(:to_binary, :first_and_last, %{first_name: first, last_name: last}) do
      "\#{last}, \#{first}"
    end
  end
  ```

  The resulting structure for the packet in code would look like this:
  ```elixir
  %Person{first_name: "", last_name: "", age: 0}
  ```

  Take note that you are required to preform any type validation as this
  is will not be done for a compound field; however, it will correctly
  hand the resulting type back for further processing if it is needed.
  With our example above for instance, you do not need to append the
  extra space the end of the string because the `c_string` processing
  will handle that for you.
  """
  defmacro compound(name, type, opts, do: block) do
    type = convert_known_types(type)
    alias EOD.Packet.Field.Compound
    {_, _, lines} = block

    fields =
      Enum.map(lines, fn {:field, _, [fieldname, [default: default]]} ->
        [name: fieldname, default: default]
      end)

    opts = Keyword.put(opts, :fields, fields)

    quote bind_quoted: [name: name, type: type, opts: opts] do
      Module.put_attribute(__MODULE__, :bin_patterns, {{name, type}, Compound, opts})
    end
  end

  @doc """
  Some fields in your packets will only specific values, when that is the
  case this helper will allow you to specify what values map to that value.
  It's important to specify a default and that it maps to one of the enums
  available.

  ### Example

  ```elixir
  defmodule Person do
    use EOD.Packet do
      field :name,  :c_string, size: [bytes: 10]
      enum :gender, :integer, size: [bytes: 1], default: 0 do
        0 -> :other
        1 -> :female
        2 -> :male
      end
    end
  end

  billy = %Person{name: "billy"}
  billy.gender #=> :other
  %{ bill | gender: :male } |> Person.to_binary #=> <<"billy", 0, 0, 0, 0, 0, 2>>
  ```
  """
  defmacro enum(name, type, opts, do: block) do
    type = convert_known_types(type)
    alias EOD.Packet.Field.Enumeration

    enums =
      block
      |> Enum.filter(&match?({:->, [_], [[_], _]}, &1))
      |> Enum.map(fn {_, _, [[raw], val]} -> {raw, val} end)

    opts = Keyword.put(opts, :enum_values, enums)

    quote bind_quoted: [name: name, type: type, opts: opts] do
      Module.put_attribute(__MODULE__, :bin_patterns, {{name, type}, Enumeration, opts})
    end
  end

  @doc """
  Some packets will have a repative structure or a series of fields that make more
  sense to be clumped together seperately.  This is where `structure` can come in
  handy.  It allows you to define these to be used multiple times.  Bear in mind,
  that just like with any field, the order is important and must match up with the
  binary data that it's reading.
  """
  defmacro structure(name, do: block) do
    new_mod = Module.concat(__CALLER__.module, Macro.expand_once(name, __CALLER__))

    quote do
      defmodule unquote(new_mod) do
        use EOD.Packet do
          substructure(true)
          unquote(block)
        end
      end

      alias unquote(new_mod)
    end
  end

  @doc """
  A list is a way match a substructure defined for a packet either a specific or
  dynamic number of times.  For matching purposes a size is required of either
  `:dynamic` or the number of elements you expect.

  ```elixir
  defmodule Dynamic do
    use EOD.Packet do
      structure Widget do
        field(:name, :pascal_string)
      end

      list(:widgets, Widget, size: :dynamic)
    end
  end
  ```

  ```elixir
  defmodule Fixed do
    use EOD.Packet do
      structure Widget do
        field(:name, :pascal_string)
      end

      list(:widgets, Widget, size: 3)
    end
  end
  ```

  You may also pass for the second parameter a list of structures; if done this
  way it will attempt to build an assorted list; matching against each type in
  the order provided.  In the following example it will first try to match a
  blank byte to `%Nothing{}` or a pascal string for `%Widget{}`.  Take care when
  using this; as you can quickly get into a senario with a bad match and enter
  a state where the substructures are wrong...

  ```elixir
  defmodule FixedAssorted do
    use EOD.Packet do
      structure Widget, do: field(:name, :pascal_string)
      structure Nothing, do: blank(using: 0x00, size: [bytes: 1], match_exactly?: true)

      list(:widgets, [Nothing, Widget], size: 3)
    end
  end
  ```
  """
  defmacro list(name, struct, opts) do
    alias EOD.Packet.Field

    quote bind_quoted: [name: name, struct: struct, opts: opts] do
      Module.put_attribute(__MODULE__, :bin_patterns, {{name, struct}, Field.List, opts})
    end
  end

  @doc false
  def __defstruct__(fields) do
    struct_fields = collect(:struct_field_pair, fields)

    quote do
      defstruct unquote(Macro.escape(struct_fields))
    end
  end

  @doc false
  def __def_from_binary__(fields) do
    binary_matches = collect(:from_binary_match, fields)
    struct_matches = collect(:from_binary_struct, fields)
    processing = collect(:from_binary_process, fields)

    quote do
      def from_binary(<<unquote_splicing(binary_matches)>>) do
        unquote_splicing(processing)
        {:ok, %__MODULE__{unquote_splicing(struct_matches)}}
      end

      def from_binary(_), do: {:error, {:no_match, __MODULE__}}
      defoverridable from_binary: 1

      if @substructure do
        def from_binary_substructure(<<unquote_splicing(binary_matches), rem::binary>>) do
          unquote_splicing(processing)
          {:ok, %__MODULE__{unquote_splicing(struct_matches)}, rem}
        end

        def from_binary_substructure(_), do: {:error, {:no_match, __MODULE__}}
        defoverridable from_binary_substructure: 1
      end
    end
  end

  @doc false
  def __def_to_binary__(fields) do
    struct_matches = collect(:to_binary_match, fields)
    binary_buildings = collect(:to_binary_bin, fields)
    processing = collect(:to_binary_process, fields)

    quote do
      def to_binary(%__MODULE__{unquote_splicing(struct_matches)}) do
        unquote_splicing(processing)
        {:ok, <<unquote_splicing(binary_buildings)>>}
      end

      def to_binary(_), do: {:error, {:no_match, __MODULE__}}
      defoverridable to_binary: 1
    end
  end

  @doc false
  def __def_packet_size__(fields) do
    size =
      collect(:size, fields)
      |> Enum.reduce(0, fn
        :anchored_dynamic, :dynamic -> :dynamic
        :anchored_dynamic, _ -> :anchored_dynamic
        :dynamic, _ -> :dynamic
        _, :dynamic -> :dynamic
        _, :anchored_dynamic -> :anchored_dynamic
        size, total -> size + total
      end)

    size =
      case size do
        int when is_integer(int) -> div(int, 8)
        any -> any
      end

    quote do
      def packet_size, do: unquote(size)
    end
  end

  defp collect(what, fields) do
    Enum.map(fields, fn {name, type, opts} ->
      apply(type, what, [{name, opts}])
    end)
    |> Enum.reject(&is_nil/1)
    |> List.flatten()
  end

  defp convert_known_types(type) do
    case type do
      :integer -> EOD.Packet.Field.Integer
      :string -> EOD.Packet.Field.String
      :pascal_string -> EOD.Packet.Field.PascalString
      :c_string -> EOD.Packet.Field.CString
      :little_int -> EOD.Packet.Field.LittleInteger
      :little_float -> EOD.Packet.Field.LittleFloat
      any -> any
    end
  end
end
