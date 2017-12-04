defmodule EOD.Socket.TCP.Encoding.CharacterOverview do
  @moduledoc false
  import EOD.Socket.TCP.ServerPacket

  def encode(
    code,
    %{ characters: characters, username: name }
  ) do

    chars_out = Enum.map(0..9, fn slot ->
      Enum.find(characters, &(&1.slot == slot))
    end)

    packet = new(code) |> write_fill_string(name, 24)

    {:ok, Enum.reduce(chars_out, packet, fn
      nil, pak ->
        pak |> fill_bytes(0x00, 188)

      char, pak ->
        <<0::3, first_race_bit::1, race_last_four::4>> = <<char.race::8>>
        pak
        |> fill_bytes(0x00, 4)
        |> write_fill_string(char.name, 24)
        |> write_byte(0x01)
        |> write_byte(char.eye_size)
        |> write_byte(char.lip_size)
        |> write_byte(char.eye_color)
        |> write_byte(char.hair_color)
        |> write_byte(char.face_type)
        |> write_byte(char.hair_style)
        |> write_byte(0x00) # TODO boots and gloves
        |> write_byte(0x00) # TODO toros and cloak on
        |> write_byte(2) # Custom mode
        |> write_byte(char.mood_type)
        |> fill_bytes(0x00, 13)
        |> write_fill_string("Camelot City", 24) # TODO location string
        |> write_fill_string("", 24) # 100 # TODO class string
        |> write_fill_string("", 24) # 124 # TODO race name
        |> write_byte(char.level)
        |> write_byte(char.class)
        |> write_byte(char.realm)
        |> write_byte(
          <<0::1, first_race_bit::1, 0::1, char.gender::1, race_last_four::4>>)
        |> write_little_16(char.model)
        |> write_byte(char.region)
        |> write_byte(0x00) # TODO Expansion stuff?
        |> write_32(0x00) # Internal database?
        |> write_byte(char.strength)
        |> write_byte(char.dexterity)
        |> write_byte(char.constitution)
        |> write_byte(char.quickness)
        |> write_byte(char.intelligence)
        |> write_byte(char.piety)
        |> write_byte(char.empathy)
        |> write_byte(char.charisma)
        |> write_little_16(0x00) # TODO Helmet
        |> write_little_16(0x00) # TODO Gloves
        |> write_little_16(0x00) # TODO Boots
        |> write_little_16(0x00) # TODO Righthanded Color
        |> write_little_16(0x00) # TODO Torso
        |> write_little_16(0x00) # TODO Cloak
        |> write_little_16(0x00) # TODO Legs
        |> write_little_16(0x00) # TODO Arms
        |> write_little_16(0x00) # TODO Helmet Color
        |> write_little_16(0x00) # TODO Gloves Color
        |> write_little_16(0x00) # TODO Boots Color
        |> write_little_16(0x00) # TODO Left handed color
        |> write_little_16(0x00) # TODO Torso Color
        |> write_little_16(0x00) # TODO Cloak Color
        |> write_little_16(0x00) # TODO Legs Color
        |> write_little_16(0x00) # TODO Arms Color
        |> write_little_16(0x00) # TODO Right Handed Model
        |> write_little_16(0x00) # TODO Left Handed Model
        |> write_little_16(0x00) # TODO Two Handed Model
        |> write_little_16(0x00) # TODO Distance Weapon Model
        |> write_byte(0xFF) # TODO Weapon Selected
        |> write_byte(0xFF) # TODO Weapon Selected
        |> write_byte(0x00) # Old SI zone check
        |> write_byte(char.constitution)
    end) |> fill_bytes(0x00, 94)}
  end
  def encode(_, _), do: {:error, :char_overview_encode}
end
