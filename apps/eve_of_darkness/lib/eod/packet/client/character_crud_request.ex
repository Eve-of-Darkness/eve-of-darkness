defmodule EOD.Packet.Client.CharacterCrudRequest do
  @moduledoc """
  This is a *big* packet with a fair amount of crazyness going on.  In a
  nutshell it is sent to the server when ever the user has updated, deleted,
  or created a new character.  What makes this packet somewhat strange is
  it sends a list of 10 characters for every request, even though only one
  character can be deleted or created at a time.  What makes this even more
  complex is the action flag for each character in the list is the same.
  Therefore, the server will have to perform extra logic to determine for
  instance, if it's a `create` action... which character is the new on that
  needs created.  Delete is the same, although; luckily you can determine
  which character to delete by filtering the ones which have an empty name.
  """
  use EOD.Packet do
    code(0xFF)
    id(:char_crud_request)

    field(:slot, :integer, size: [bytes: 1])
    field(:name, :pascal_string, type: :little, size: 4, null_terminated: true)

    blank(using: 0x18, size: [bytes: 1])
    blank(using: 0, size: [bytes: 3])

    field(:custom_mode, :integer, size: [bytes: 1])
    field(:eye_size, :integer, size: [bytes: 1])
    field(:lip_size, :integer, size: [bytes: 1])
    field(:eye_color, :integer, size: [bytes: 1])
    field(:hair_color, :integer, size: [bytes: 1])
    field(:face_type, :integer, size: [bytes: 1])
    field(:hair_style, :integer, size: [bytes: 1])
    blank(using: 0x00, size: [bytes: 3])
    field(:mood_type, :integer, size: [bytes: 1])
    blank(using: 0x00, size: [bytes: 8])

    enum :action, :integer, size: [bytes: 4], default: 0 do
      0x00000 -> :nothing
      0x30000 -> :delete
      0x10000 -> :create
      0x20100 -> :update_cosmetics
      0x20200 -> :update_attributes
      0x20300 -> :update_attributes_and_cosmetics
    end

    # Skipping unknown byte
    blank(using: 0x00, size: [bytes: 1])

    field(:location, :pascal_string, size: 4, type: :little, null_terminated: true)
    field(:class_name, :pascal_string, size: 4, type: :little, null_terminated: true)
    field(:race_name, :pascal_string, size: 4, type: :little, null_terminated: true)

    field(:level, :integer, size: [bytes: 1])
    field(:class, :integer, size: [bytes: 1])
    field(:realm, :integer, size: [bytes: 1])

    compound :race_and_gender, :integer, size: [bytes: 1] do
      field(:race, default: 0)
      field(:gender, default: 0)
    end

    field(:model, :little_int, size: [bytes: 2])
    field(:region, :integer, size: [bytes: 1])

    blank(using: 0x00, size: [bytes: 5])

    field(:strength, :integer, size: [bytes: 1])
    field(:dexterity, :integer, size: [bytes: 1])
    field(:constitution, :integer, size: [bytes: 1])
    field(:quickness, :integer, size: [bytes: 1])
    field(:intelligence, :integer, size: [bytes: 1])
    field(:piety, :integer, size: [bytes: 1])
    field(:empathy, :integer, size: [bytes: 1])
    field(:charisma, :integer, size: [bytes: 1])

    # Skipping equipment and zone bytes
    blank(using: 0x00, size: [bytes: 45])

    # race and gender are woven together in a single byte, this untangles
    # them from each other and splices them back together
    defp compound(:from_binary, :race_and_gender, int) do
      <<_::1, first_race_bit::1, _::1, gender::1, race_last_four::4>> = <<int::8>>
      <<race::8>> = <<0::3, first_race_bit::1, race_last_four::4>>
      %{race: race, gender: gender}
    end

    defp compound(:to_binary, :race_and_gender, %{race: race, gender: gender}) do
      <<0::3, first_race_bit::1, race_last_four::4>> = <<race::8>>
      <<num::8>> = <<0::1, first_race_bit::1, 0::1, gender::1, race_last_four::4>>
      num
    end
  end
end
